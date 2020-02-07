# snoing-2.0

[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/3807) [![https://img.shields.io/badge/hosted-dockerhub-blue](https://img.shields.io/badge/hosted-dockerhub-blue)](https://hub.docker.com/r/jamierajewski/snoing-2.0)


Singularity and Docker recipes to build a SNO+ environment for RAT.

For regular usage, simply download the pre-built container with the following instructions for your container platform of choice. For advanced users, see the build instructions below.

# [PLEASE READ]

1. Singularity and Docker are similar tools but operate slightly differently. Singularity acts more like an overlay, where
you have access to your filesystem as you would **outside** the container (with the same rights as you'd have outside), 
whereas Docker provides you with an isolated virtual filesystem (meaning you **can't** access your files from outside 
the container). In summary, it is best to **mount** whatever directories you may need when running the container, whether 
in Docker or Singularity (see the section "**To write/execute files from directories outside of RAT/launch 
directory**" below).

2. Regardless of whether you download or build the container, you can use and develop RAT as you see fit as it is external 
to the container.

3. Instructions to install Singularity can be found [here.](https://github.com/sylabs/singularity/blob/master/INSTALL.md) For
Docker, instructions for each platform can be found [here.](https://docs.docker.com/install/#supported-platforms)

4. As the DIRAC system no longer supports SL6, there is no longer a need to maintain an SL6 version when pushing new RAT releases to cvmfs. Therefore, the only image offered here is based on SL7.

5. To be clear, if you wish to use the prebuild image, then you do NOT need to clone this repo; simply follow the
instructions below.

6. At the moment, **display pass-through** is a **known issue**; please see the Github issue, or at the bottom of this
documentation in the FAQ section for more information.

# To download the pre-built container
**If on a shared system/cluster**, Singularity should be available so use the following command to obtain the latest 
version of the container:

`singularity pull --name snoing.sif docker://jamierajewski/snoing-2.0:latest`

Ensure that the Singularity version you are using is **&ge;3.2**

At the moment, certain clusters (like Cedar) have firewall rules preventing access to SingularityHub. This can make it
difficult to use unless someone pulls the image locally first, then copies it to a shared location on the cluster.

***
**If on your own local machine**, Docker should be used as it is easier to install. 
The command to obtain the latest version of the container for Docker is:

`docker pull jamierajewski/snoing-2.0:latest`

Docker doesn't actually create a file in your working directory in the same way that Singularity does; rather, it 
downloads the image layers and adds an entry to your local **Docker registry** which can be viewed by going:

`docker images`

This difference doesn't have an effect on how it is actually used though.

# Instructions on how to use the container with RAT

**To build RAT for the first time**:
- Clone RAT from GitHub
- Enter the following command, filling in the path to RAT with your own. This will mount your RAT repo to the directory 
/rat inside the container:

For *Singularity*:

`singularity shell -B path/to/rat:/rat snoing.sif`

For *Docker*:

`docker run -ti -v /absolute/path/to/rat:/rat jamierajewski/snoing-2.0 bash`

*Note* - the -v flag operates the same as -B in Singularity BUT you **must** provide it with an absolute path (one starting at /); relative paths (the path from where you are now) will **not** work.

- Then, once you are within the container (Docker or Singularity), run this command to setup the RAT environment:

`source /home/scripts/setup-env.sh`

- Finally, run this command to build RAT:

`source /home/scripts/build-rat.sh`

- RAT is now ready to use! Look at the instructions below for how to run it

***
**To exit the container (Singularity and Docker)**:

`exit`

***
**To run RAT**:

- First, get a shell into the container with your RAT bound into it:
(It is **important** to **mount your rat directory to /rat** as the build scripts look there for it!)
  
For *Singularity*:

`singularity shell -B path/to/rat:/rat snoing.sif`

For *Docker*:

`docker run -ti -v /absolute/path/to/rat:/rat jamierajewski/snoing-2.0 bash`

- Next, run the following command to source all environment scripts necessary for RAT:

`source /home/scripts/setup-env.sh`

- RAT is now ready for use, and you should be able to access the RAT repo itself at /rat. To use other 
directories, additional bind mounts are necessary (see below).

***
**To use GUI apps like ROOT**:

- The process is different on each OS but I will outline steps here to make it work on each. Note that these instructions
  assume that since you are on your own machine, you are using **Docker**. Singularity may work with graphics as it is, but
  Docker will be the definitive solution.
  
  For **Linux**:
  
  docker run -ti **--user $(id -u) -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix** -v /absolute/path/to/rat:/rat
  jamierajewski/snoing-2.0
  
  As you can see, the difference is a few extra options. This command is getting a bit out of control to
  launch into, so feel free to set an alias in your .bashrc.


***
**To update RAT**:

- Outside of the container, `cd` into your RAT repo, and run:

`git fetch && git merge`
- Then, run the container:

For *Singularity*:

`singularity shell -B path/to/rat:/rat snoing.sif`

For *Docker*:

`docker run -ti -v "$(pwd)"/rat:/rat jamierajewski/snoing-2.0 bash`

- Source the environment:

`source /home/scripts/setup-env.sh`

- Finally, run scons to rebuild RAT:

`scons`

***
**To write/execute files from directories outside of RAT/launch directory**:
- Add additional bind mounts to your Singularity or Docker command
- Example:

For *Singularity*:

`singularity shell -B path/to/rat:/rat,/other/path:/stuff snoing.sif`

For *Docker*:

`docker run -ti -v /absolute/path/to/rat:/rat -v /other/path:/stuff jamierajewski/snoing-2.0 bash`

- Now in the container, you have access to /other/path at /stuff

***
**To use a specific branch of RAT**:
- Ensure you git checkout to the branch OUTSIDE the container to avoid issues, then run RAT like above

# [ADVANCED]
# To build the container
To build, you must have **root permissions** and **Singularity or Docker installed on your machine** (the image can be 
moved to a cluster once it has been built). Install Singularity manually, or do `sudo apt-get install singularity-container` on debian-based systems (like Ubuntu) to get an older but capable Singularity.

Download the `Singularity` recipe file, and run the following command, which will produce a container file 
called `snoing.sif`:

`sudo singularity build snoing.sif Singularity`

***
# To run multiple RAT instances
If you want to use multiple RAT instances simultaneously, then all you have to do is run an instance of this container 
with each version of RAT that you want; do NOT try mounting multiple RATs to the SAME instance as the image was 
not configured for this.

***
# To modify Geant4
If you need to edit Geant4 for any reason, you will have to modify the recipe file and make your changes accordingly, then
rebuild the container.

# F.A.Q.

**I'm seeing "Error getting image manifest using url..." when I try to pull the container**
- This seems to happen on the clusters, most likely due to the firewall. Try pulling the container on your local machine, 
and transfer the image to your cluster with scp.

***
**When I try to open the TBrowser/another GUI app, it doesn't show**
- This is a known issue, and happens for two reasons. If you are trying to use the Docker version on your own machine, Docker
does not have access to the display by default so there is some configuration required.

The other issue is if you are trying to do this on a cluster with the Singularity version, you will notice the same thing. 
Because you are remotely connected, the display is not configured by default to also connect. 

I will update this documentation when workarounds have been found, but for the time being, the only confirmed method of
getting the display to work is by using **singularity** on **your own machine** (if possible).
