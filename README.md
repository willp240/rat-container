# snoing-2.0

[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/3807) [![https://img.shields.io/badge/hosted-dockerhub-blue](https://img.shields.io/badge/hosted-dockerhub-blue)](https://hub.docker.com/r/jamierajewski/snoing-2.0)


A singularity recipe for building a SNO+ environment for RAT. 

For regular usage, simply download the pre-built container with the following instructions. For advanced users, see the build instructions below. 

# [PLEASE READ]

1. Singularity and Docker are similar tools but operate slightly differently. Singularity acts more like an overlay, where
you have access to your filesystem as you would **outside** the container (with the same rights as you'd have outside), 
whereas Docker provides you with an isolated virtual filesystem (meaning you **can't** access your files from outside 
the container). 

In summary, it is best to **mount** whatever directories you may need when running the container, whether in Docker 
or Singularity (see the section "**To write/execute files from directories outside of RAT/launch directory**" below).

2. Regardless of whether you download or build the container, you can use and develop RAT as you see fit as it is external 
to the container.

3. Instructions to install Singularity can be found [here.](https://github.com/sylabs/singularity/blob/master/INSTALL.md) For
Docker, instructions for each platform can be found [here.](https://docs.docker.com/install/#supported-platforms)

# To download the pre-built container
**If on a shared system/cluster**, Singularity should be available so use the following command to obtain the latest 
version of the container:

`singularity pull --name snoing.sif shub://jamierajewski/snoing-2.0`

I suggest this be done on your local machine due to the firewall on clusters not allowing SingularityHub downloads through 
(until the container is available through CVMFS). If you have issues with this, please contact me.

**If on your own local machine**, Docker should be used (especially on **MacOS/Windows**) as it is easier to install. The command to obtain the latest version of the container for Docker is:

`docker pull jamierajewski/snoing-2.0`

# Instructions on how to use the container with RAT

**To build RAT for the first time**:
- Clone RAT from GitHub
- Enter the following command, filling in the path to RAT with your own. This will mount your RAT repo to the directory 
/rat inside the container:

For **Singularity**:

`singularity shell -B path/to/rat:/rat snoing.sif`

- Then, once you are within the container, run this command to setup the RAT environment:

`source /home/scripts/setup-env.sh`

- Finally, run this command to build RAT:

`source /home/scripts/build-rat.sh`
- RAT is now ready to use! Look at the instructions below for how to run it

**To exit the container**:

`exit`

**To run RAT**:
- Enter the following command, filling in the path to RAT with your own:

`singularity shell -B path/to/rat:/rat snoing.simg`
- It is **important** to **mount your rat directory to /rat** as the build scripts look there for it!
- RAT is primed, now you can navigate to /rat to run things in the repository. To use other directories as well, see below.

**To update RAT**:

- Outside of the container, `cd` into your RAT repo, and run:

`git fetch && git merge`
- Then, run the container:

`singularity shell -B path/to/rat:/rat snoing.simg`
- Finally, run scons to rebuild RAT:

`scons`

**To write/execute files from directories outside of RAT/launch directory**:
- Add additional bind mounts to your singularity shell command
- Example:

`singularity run --app build-rat -B path/to/rat:/rat,other/path:/stuff snoing.simg`
- Now in the container, you have access to other/path by going to /stuff

**To use a specific branch of RAT**:
- Ensure you git checkout to the branch OUTSIDE the container to avoid issues, then run RAT like above

**To see this help message on the command line**:

`singularity help snoing.simg`

# [ADVANCED]
# To build the container
To build, you must have **root permissions** and **singularity installed on your machine** (the image can be moved to a cluster once it has been built). Install singularity manually, or do `sudo apt-get install singularity-container` on debian-based systems (like Ubuntu).

Download the `Singularity` recipe file, and run the following command, which will produce a container file called `snoing.simg`:

`sudo singularity build snoing.simg Singularity`

# To run multiple RAT instances
If you want to use multiple RAT instances simultaneously, then all you have to do is run an instance of this container with each version of RAT that you want; do NOT try mounting multiple RATs to the SAME instance as the image was not configured for this.

# To modify Geant4
If you need to edit Geant4 for any reason, you will have to modify the recipe file and make your changes accordingly.

# F.A.Q.

I'm seeing "Error getting image manifest using url..." when I try to pull the container
- This seems to happen on the clusters, most likely due to the firewall. Try pulling the container on your local machine, and transfer the image to your cluster with scp.
