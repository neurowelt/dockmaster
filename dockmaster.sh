#!/bin/bash
#
# Build & run Docker containers based on a config file

# Get config file to run the master
while [ $# -gt 0 ] ; do
    case $1 in
        -c | --config)
            shift
            config=$1
            ;;
        -h | --help)
            echo "Usage: $0 -c path/to/config.ini"
            echo "Options:"
            echo "  -c, --config: Config (.ini) file containig all necessary parameters"
            exit 0
            ;;
    esac
    shift
done

# Declare necessary variables
declare -a envs
declare -a devices
declare -a cmd_scripts
declare -a dockerfiles
declare -a image_names
declare -a container_names
run_containers=true
delete_containers=true
delete_images=true
run_as_daemon=false

#######################################
# Config reading function
# Arguments:
#   Path to a config file
# Returns:
#   Exit 1 if file is not .ini, assign vars otherwise
#######################################
read_config() {
    local config_file="$1"
    local selection=""

    # Check if file is a .ini file
    if ! [[ $config_file == *.ini ]] ; then
        echo "Config file must be a .ini file."
        exit 1
    fi

    # Read the config file & assign variables
    while IFS='=' read -r key value; do

        # Skip comments
        if [[ $key == \#* ]] ; then
            continue
        fi

        # Trim whitespace
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | tr -d '[:space:]')

        # Keep section name and handle variables accordingly
        if [[ $key == \[*] ]] ; then
            section=$(echo "$key" | sed 's/^\[\(.*\)\]$/\1/')
        else
            # Assign variables
            case $section in
                "env")
                    if ! [[ -z $key ]] || ! [[ -z $value ]]; then
                        envs+=("$key=$value")
                    fi
                    ;;
                "execution")
                    case $key in
                        "device")
                            IFS=',' read -ra devices <<< "$value"
                            ;;
                        "cmd_scripts")
                            IFS=',' read -ra cmd_scripts <<< "$value"
                            ;;
                    esac
                    ;;
                "docker")
                    case $key in
                        "dockerfiles")
                            IFS=',' read -ra dockerfiles <<< "$value"
                            ;;
                        "image_names")
                            IFS=',' read -ra image_names <<< "$value"
                            ;;
                        "container_names")
                            IFS=',' read -ra container_names <<< "$value"
                            ;;
                        "run_containers")
                            run_containers=$value
                            ;;
                        "delete_containers")
                            delete_containers=$value
                            ;;
                        "delete_images")
                            delete_images=$value
                            ;;
                        "run_as_daemon")
                            run_as_daemon=$value
                            ;;
                    esac
                    ;;
            esac
        fi
    done < "$config_file"
}

#######################################
# Create Docker build command
# Arguments:
#   Image name and Dockerfile path
# Returns:
#   `docker build` command, exit 1 without args
#######################################
create_docker_build_cmd() {
    local image_name="$1"
    local dockerfile="$2"
    local build_args=""

    # Exit if image name or Dockerfile is empty
    if [[ -z $image_name ]] || [[ -z $dockerfile ]] ; then
        echo "Image name or Dockerfile path is empty - cancelling process."
        exit 1
    fi

    # Loop through the envs array and construct build-arg options
    for env in "${envs[@]}"; do
        IFS='=' read -r key value <<< "$env"
        build_args+="--build-arg $key=$value "
    done

    # Construct build command
    local docker_command="docker build $build_args -t $image_name -f $dockerfile ."

    echo "$docker_command"
}


#######################################
# Create Docker run command
# Arguments:
#   Image & container names, CMD script path, device, run as daemon
# Returns:
#   `docker run` command, exit 1 without args
#######################################
create_docker_run_cmd() {
    local image_name="$1"
    local container_name="$2"
    local cmd_script="$3"
    local device="$4"
    local as_daemon="$5"

    # Exit if args are not provided
    if [[ -z $image_name ]] || [[ -z $container_name ]] ; then
        echo "Image name or container name is empty - cancelling process."
        exit 1
    fi

    # Prepare run arguments 
    local run_args=""
    if [[ ! -z $device ]] ; then
        run_args="--gpus device=$device"
    fi
    if [[ ! -z $as_daemon ]] && [[ $as_daemon = true ]] ; then
        run_args+=" -d"
    fi

    # Create run command
    local docker_command="docker run $run_args --name $container_name -t $image_name $cmd_script"

    echo "$docker_command"
}

#######################################
# Check if given file exists
# Arguments:
#   File path
# Returns:
#   Exit 1 if file does not exist
#######################################
check_file_exists() {
    local file=$1
    echo "Checking if file $file exists..."
    if [[ ! -f $file ]] ; then
        echo "File $file does not exist - cancelling process."
        exit 1
    fi
}

# Read passed config
read_config "$config"

# Checks if basic params are empty
if [[ -z $dockerfiles ]] ; then
    echo "dockerfiles is a required parameter - cancelling process."
    exit 1
fi
if [[ -z $image_names ]] ; then
    echo "image_names is a required parameter - cancelling process."
    exit 1
fi
if [[ -z $container_names ]] ; then
    echo "container_names is a required parameter - cancelling process."
    exit 1
fi

# If devices are provided, check if they exist
if [[ ! -z $devices ]] ; then
    if ! [ -x "$(command -v nvidia-smi)" ]; then
        echo "Devices were provided, but CUDA is not installed - cancelling process."
        exit 1
    fi
    IFS="\n" read -ra available_devices <<< $(nvidia-smi -L | grep -o "[0-9]:" | tr -d ":")
    for device in "${devices[@]}" ; do
        exists=false
        for available_device in "${available_devices[@]}" ; do
            if [[ $device -eq $available_device ]] ; then
                exists=true
                break
            fi
        done
        if [[ $exists = false ]] ; then
            echo "Device $device does not exist, but was requested - cancelling process."
            exit 1
        fi
    done
fi

# Check if parameters of list type are matching length
if [[ ${#dockerfiles[@]} -ne ${#image_names[@]} ]] ; then
    echo "Number of Dockerfiles and image names does not match - cancelling process."
    exit 1
fi
if [[ ${#dockerfiles[@]} -ne ${#container_names[@]} ]] ; then
    echo "Number of Dockerfiles and container names does not match - cancelling process."
    exit 1
fi
if ! [[ -z $cmd_scripts ]] ; then
    if [[ ${#dockerfiles[@]} -ne ${#cmd_scripts[@]} ]] ; then
        echo "Number of Dockerfiles and CMD scripts does not match - cancelling process."
        exit 1
    fi
fi

# Check if Dockerfiles exist
for dockerfile in "${dockerfiles[@]}" ; do
    check_file_exists "$dockerfile"
done

# Check if CMD scripts exist
for cmd_script in "${cmd_scripts[@]}" ; do
    check_file_exists "$cmd_script"
done

# Building Docker images
echo "Starting Docker bulding process..."
typeset -i nr
for ((nr=0;nr<${#dockerfiles[@]};nr++)) ; do
    docker_command=$(create_docker_build_cmd "${image_names[$nr]}" "${dockerfiles[$nr]}")
    echo "Building Docker image ${image_names[$nr]} from Dockerfile ${dockerfiles[$nr]}..."
    echo "Running command: $docker_command"
    $docker_command
done
echo "Docker building process finished."

# Do not delete if running as daemons
if [[ $run_as_daemon = true ]] ; then
    echo "Running as daemons, will not delete containers or images."
    delete_containers=false
    delete_images=false
fi

# Running Docker containers
echo "Starting Docker running process..."
typeset -i nr
for ((nr=0;nr<${#container_names[@]};nr++)) ; do
    if [[ $run_containers = true ]] ; then
        docker_command=$(create_docker_run_cmd "${image_names[$nr]}" "${container_names[$nr]}" "${cmd_scripts[$nr]}" "${devices[$nr]}" "$run_as_daemon")
        echo "Running Docker container ${container_names[$nr]}..."
        $docker_command
    fi
    if [[ $delete_containers = true ]] ; then
        echo "Deleting Docker container ${container_names[$nr]}..."
        docker rm "${container_names[$nr]}"
        if [[ $delete_images = true ]] ; then
            echo "Deleting Docker image ${image_names[$nr]}..."
            docker rmi "${image_names[$nr]}"
        fi
    fi
done
echo "Docker running process finished."
