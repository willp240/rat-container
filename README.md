# rat-container

[![https://img.shields.io/badge/hosted-dockerhub-blue](https://img.shields.io/badge/hosted-dockerhub-blue)](https://hub.docker.com/r/snoplus/rat-container)


Apptainer (formerly Singularity) and Docker recipes to build a SNO+ environment for RAT.

For regular usage, simply download the pre-built container with the following instructions for your container platform of choice. For advanced users, see the build instructions below.

***IF THE DOCKERHUB LINK STOPS WORKING, SOMEONE MAY HAVE TO BUILD AND REUPLOAD THE CONTAINER TO DOCKERHUB DUE TO A CHANGE IN THEIR POLICY***

As of ***November 1, 2020*** Docker is implementing an inactive image removal policy, meaning in a free account (which is where this container is hosted) if the container is not ***updated or pulled for 6 consecutive months*** it will be ***deleted***. This isn't a huge issue, someone will just have to do the following:
- Build the container manually from the image file in this repository according to the instructions below
- Upload it to another Dockerhub repository
- Update the download links that reference the Dockerhub location with the new location

# FEATURES
- Full RAT-compatible environment, including ROOT5 (ROOT6 version now available), GEANT4 and scons
- Can build any version of RAT
- GUI output support on all operating systems
- TensorFlow and CppFlow (CPU-only for the time being)
- Apptainer and Docker compatibility
- *Cluster-compatible

*The image can be uploaded manually, pulled directly (if the cluster firewall permits) or run from /cvmfs; however, the cvmfs
image is not always up-to-date with the repo version. This has been [identified as an issue](https://github.com/snoplus/rat-container/issues/8) with a possible solution posed.

# [PLEASE READ]

1. Apptainer and Docker are similar tools but operate slightly differently. Apptainer acts more like an overlay, where
you have access to your filesystem as you would **outside** the container (with the same rights as you'd have outside),
whereas Docker provides you with an isolated virtual filesystem (meaning you **can't** access your files from outside
the container). In summary, it is best to **mount** whatever directories you may need when running the container, whether
in Docker or Apptainer (see the section "**To write/execute files from directories outside of RAT/launch
directory**" below).

2. Regardless of whether you download or build the container, you can use and develop RAT as you see fit as it is external
to the container.

3. Instructions to install Apptainer can be found [here.](https://github.com/apptainer/apptainer/blob/v1.0.0-rc.1/INSTALL.md) For
Docker, instructions for each platform can be found [here.](https://docs.docker.com/install/#supported-platforms)
- **For Docker, version 19.0+ is required**

4. **To be clear, if you wish to use the prebuilt image, then you do NOT need to clone this repo; simply follow the
instructions below.**

5. On Cedar, when using apptainer, first do:
```
module load apptainer
```

# New Video Tutorial (slightly outdated - no longer necessary to source the setup-env.sh on startup, and we no longer have separate ROOT5/6 tags, just MAIN)
- [Available here (Requires SNO+ DocDB access)](https://www.snolab.ca/snoplus/private/DocDB/0062/006281/001/RAT%20container%20tutorial.mp4)

# To download the pre-built container
**If on a shared system/cluster**, Apptainer should be available so use the following command to obtain the latest
version of the container (for some older versions of Apptainer, you may need to use the command 'singularity', rather than 'apptainer'):
```
apptainer pull --name rat-container.sif docker://snoplus/rat-container:main
```
The tag (in the above command, `main`) could be replaced with the desired tag (although currently, only MAIN is maintained).

At the moment, certain clusters (like Cedar) have firewall rules preventing access to SingularityHub. There is a version of
the image located at `/cvmfs/snoplus.egi.eu/el9/sw/containers/rat-container.sif` but keep in mind that it may not always be
the latest version (this shouldn't matter if you are simply building/running RAT).

***
**If on your own local machine**, Docker should be used as it is easier to install.
The command to obtain the latest version of the container for Docker is:
```
docker pull snoplus/rat-container:main
```
The tag (in the above command, `main`) can be replaced with the desired tag.

Docker doesn't actually create a file in your working directory in the same way that Apptainer does; rather, it
downloads the image layers and adds an entry to your local **Docker registry** which can be viewed by going:
```
docker images
```
This difference doesn't have an effect on how the container is actually used.

# Instructions on how to use the container with RAT

**To build RAT for the first time**:
- Clone RAT from GitHub (**NOTE** - If on Windows, make sure you run `git config --global core.autocrlf input` prior to
  cloning or else Git will automatically change the Unix line-endings to Windows (which **will break the next steps**)
- Enter the following command, filling in the path to RAT with your own.
  This will mount your RAT repo to the directory `/rat` inside the container:

  For *Apptainer*:
  ```
  apptainer shell -B path/to/rat:/rat rat-container.sif
  ```
  For *Docker*:
  ```
  docker run -ti --init --rm -v /absolute/path/to/rat:/rat snoplus/rat-container
  ```
  *Note* - the `-v` flag operates the same as `-B` in Apptainer BUT you **must** provide it with an absolute path (one starting at /);
  relative paths (the path from where you are now) will **not** work.

- Once in the container, Apptainer users need to run the following:
  ```
  source /home/scripts/setup-env.sh
  ```
  In **Docker** this is **unnecessary** as Docker sources it automatically on launch.
  You may see a message about how it could not find `/rat/env.sh`; this is expected as you have not built RAT yet.
  If the build is successful, you shouldn't see this message next time.

  - Finally, run this command to build RAT:
  ```
  source /home/scripts/build-rat.sh
  ```
  Alternatively, `scons` can manually be called while in the `/rat` folder.

- RAT is now ready to use! Look at the instructions below for how to run it

***
**To exit the container (Apptainer and Docker)**:
```
exit
```

***
**To run RAT**:

- First, get a shell into the container with your RAT bound into it:
(It is **important** to **mount your rat directory to /rat** as the build scripts look there for it!)

  For *Apptainer*:
  ```
  apptainer shell -B path/to/rat:/rat rat-container.sif
  ```
  For *Docker*:
  ```
  docker run -ti --init --rm -v /absolute/path/to/rat:/rat snoplus/rat-container
  ```
- RAT is now ready for use, and you should be able to access the RAT repo itself at `/rat`. To use other
directories, additional bind mounts are necessary (see below).

***
**To use GUI apps like ROOT's TBrowser**:
(This is based on CERN's documentation for [running ROOT with graphics](https://hub.docker.com/r/rootproject/root-ubuntu16/))

- The process is different on each OS but I will outline steps here to make it work on each. Note that these instructions
  assume that since you are on your own machine, you are using **Docker**. Apptainer may work with graphics as it is, but
  these Docker solutions are the only ones that are tested and confirmed to be working.

  For **Linux**:
  ```
  docker run -ti --init --rm --user $(id -u) -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /absolute/path/to/rat:/rat snoplus/rat-container
  ```
  As you can see, the difference is a few extra options. As the command has gotten so large, you can [set an alias in your .bashrc](https://askubuntu.com/a/17538) to something much shorter and more convenient.

  For **Windows 10**:

  As of the new May 2020 Windows update, the Windows Subsystem for Linux (WSL) version 2 is out. Docker desktop can be
  configured to use this which is the recommended way to run Docker on Windows. Ensure WSL2 is enabled in the Docker Desktop
  settings, then follow these instructions:

  1. Download and install [Xming](https://sourceforge.net/projects/xming/)
  2. When Windows prompts you to allow it in the firewall, do so.
  3. Finally, restart Xming and now run the following command in Powershell or WSL2:
  ```
  docker run --init --rm -ti -e DISPLAY=host.docker.internal:0 -v /absolute/path/to/rat:/rat snoplus/rat-container
  ```

  For **macOS**:

  1. Install [XQuartz](https://www.xquartz.org/)
  2. Open XQuartz, and then go XQuartz -> Preferences -> Security, and tick the box "Allow connections from network clients"
  3. Run `xhost + 127.0.0.1` which will whitelist your local IP
  4. Finally, you can run the container with the following:
  ```
  docker run --rm --init -ti -v /tmp/.X11-unix:/tmp/.X11-unix -v /absolute/path/to/rat:/rat -e DISPLAY=host.docker.internal:0 snoplus/rat-container
  ```
  (The order `-ti` instead of `-it` seems to only matter for MacOS)

***
**To update RAT**:

- Outside of the container, `cd` into your RAT repo, and run:
  ```
  git pull origin master
  ```
- Then, run the container:

  For *Apptainer*:
  ```
  apptainer shell -B path/to/rat:/rat rat-container.sif
  ```
  For *Docker*:
  ```
  docker run -ti --init -v "$(pwd)"/rat:/rat snoplus/rat-container
  ```
- Navigate to the RAT directory:
  ```
  cd /rat
  ```
- Finally, run the build script (`/home/scripts/build-rat.sh`) or `scons` directly to rebuild RAT:
  ```
  scons
  ```

***
**To write/execute files from directories outside of RAT/launch directory**:
- Add additional bind mounts to your Apptainer or Docker command
- Example:

  For *Apptainer*:
  ```
  apptainer shell -B path/to/rat:/rat,/other/path:/stuff rat-container.sif
  ```
  For *Docker*:
  ```
  docker run --init --rm -ti -v /absolute/path/to/rat:/rat -v /other/path:/stuff snoplus/rat-container
  ```
- Now in the container, you have access to /other/path at /stuff

***
**To use a specific branch of RAT**:
- Ensure you git checkout to the branch OUTSIDE the container to avoid issues, then run RAT like above

***
**To use TensorFlow/cppflow**:
- The libraries are already installed (tensorflow at /usr/local/lib, cppflow repo is at /home/software) and
  the environment variables are set in the setup-env.sh script, so you should be able to just use it after sourcing

# [ADVANCED]
# To build the container
To build, you must have **root permissions** and **Docker installed on your machine**. Docker installation instructions can be found [here](https://docs.docker.com/get-docker/) for each OS.

To rebuild the container:

1. Clone this repository
2. Navigate into `MAIN`
3. Edit `Dockerfile`, which is the recipe on what you would like to put into your container
4. Once you are happy with your changes, navigate back to the root of the repository and run:
   ```
   docker build -t YOUR_CONTAINER_TAG -f MAIN/Dockerfile .
   ```
   where `YOUR_CONTAINER_TAG` is the name you would like to give to your container. Also, ensure you change `MAIN` to whichever version you want

5. This will build your container with your tag name, which you can then use in the same way as in the above guide, but instead of
   ```
   docker run ... snoplus/rat-container
   ```
   you will now run:
   ```
   docker run ... YOUR_TAG_NAME
   ```

6. [OPTIONAL] If you would like to share or back up your container image, you can push it to Dockerhub. You can follow [the official documentation](https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub) to learn how

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

**On macOS I see "docker: Error response from daemon: Mounts denied: The path ... is not shared from OS X and is not known to Docker."**
- This happens because Docker only allows mounting from 4 locations by default to follow Apple's sandbox guidelines; these locations are:
  ```
  /Users
  /tmp
  /private
  /Volumes
  ```
- Ensure your RAT repository is stored in one of these locations (the easiest would be simply under `/Users/[your username]/rat`)

**I'm seeing "/usr/bin/bash: /usr/bin/bash: cannot execute binary file" when I try to run the container**
- This happens because you have `bash` at the end of your run command; in the new version, this is no longer necessary as it
will launch bash by itself.

**I'm seeing "Error getting image manifest using url..." when I try to pull the container**
- This seems to happen on the clusters, most likely due to the firewall. Try pulling the container on your local machine,
and transfer the image to your cluster with scp.

**I'm seeing errors when running scons to rebuild RAT after updating to a new RAT release**
- This happens when you use the GUI-enabled docker command (not the standard command) when launching the container to rebuild
RAT. Please review the instructions for how to update RAT above for the correct way to update.
- This can also happen if you don't run `scons` within the `/rat` directory as it won't be able to find the correct files

**When I try to open the TBrowser/another GUI app, it doesn't show**
- This is a known issue, and happens for two reasons. If you are trying to use the Docker version on your own machine, Docker
does not have access to the display by default so there is some configuration required.
- The other issue is if you are trying to do this on a cluster with the Apptainer version, you will notice the same thing.
Because you are remotely connected, the display is not configured by default to also connect.
- Known methods for getting a GUI working are listed in a section above for each OS under Docker.
