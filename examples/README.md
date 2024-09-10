# Docker Master - examples

To run each example please run the following commands from the main repository directory:
* `basic` example - simple loop & environment variable retrieval:

    ```bash
    # Change directory
    cd examples/basic

    # Run the dockmaster (will remove container after worker finishes)
    bash ../../dockmaster.sh -c basic.ini
    ```

* `advanced` exzample - training & inference services ran as two separate containers in daemon mode:

    ```bash
    # Change directory
    cd examples/advanced

    # Run the dockmaster (will create two images and containers, ran as daemons)
    bash ../../dockmaster.sh -c advanced.ini

    # Wait for containers to run, then check if they are running
    docker ps
    
    # If both containers are on the list, run the Python check
    python check_containers.py

    # After the check is complete, remove the containers and images
    docker rm example_container_1
    docker rm example_container_2
    docker rmi example_img_1
    docker rmi example_img_2
    ```

    > [!NOTE]
    > `check_containers.py` requires only the basic Python libraries (`requests` and `hashlib`)
