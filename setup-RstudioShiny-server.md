---
title: "How to setup a (not so) personal analytics server"
author: "Luca Valnegri (l.valnegri@datamaps.co.uk)"
date: "10/09/2016"
---

## Introduction 

[*R*](http://www.r-project.org/) is one of the most popular programming language in the world, it's free to use, it has a vast, vibrant and supporting community, but its environment is quite simple and dry, even if powerful, and its learning curve is quite steep. Moreover, there is no unique interface shared among different OS; actually, on Linux there is only the command line.

Here comes [*RStudio*](http://www.rstudio.com/), as the nowadays most popular IDE for *R*, that offers great productivity enhancements, and a unique GUI for Linux, Windows and Mac. 

[*Shiny*](http://shiny.rstudio.com/gallery/) and [*RMarkdown*](http://rmarkdown.rstudio.com/gallery.html) are two relatively recent *R* packages, that allow users to easily convert *R* code into interactive webpages and dynamic documents online. 

Finally, *RStudio Server* and *Shiny Server*, in their open source versions, allow any researcher or analyst to easily share Shiny *apps* and RMarkdown documents with their team members, colleagues and/or stakeholders in their organization, or anyone in the world with access to the Internet. 

This short doc explains the essential for setting up both *RStudio Server* and *Shiny Server* on an *Ubuntu* Machine in the Cloud using the *Google Compute Engine*, part of their quite complete **IaaS** offer called *Google Cloud Platform*. The current free trial consists in $300 to use on a period of 2 months, that allows anyone to learn how to build and use a powerful analytics machine in minutes without breaking the bank (actually, without even spending 1p). What follows, though, is not an introduction to R or how to write a Shiny app. 


## Setting up the data-analytics framework

### Create a GCE Virtual Machine

 - IF you still have to join *GCE*, go to the [GCE Home page](https://cloud.google.com/compute/) and click *Try it for free*. You are now asked to enter Google Mail credential, or to create a new account. Once done, you have to fill the information about the billing method, and then click *Start your free trial*. You're not going to be charged, though, unless you explicitly agree to continue at the end of the trial, or when the $300 have all been consumed.
 - Go to the [Project console](https://console.cloud.google.com/iam-admin/projects) and click *CREATE PROJECT* at the top. In the upcoming pop up enter a suitable **name**, then click *Show advanced options...*, and choose **europe-west**. Click *Create*. Give the system some time...
 - Go to [VM Instances console](https://console.cloud.google.com/compute/instances), select the project you want to use and wait for the page to end loading.
 - Click the *Create instance button*

   - Name your future VM correspondingly
   - Choose one of the **europe-west1** zone
   - Under *Machine type* choose *Customise*, and then **4 Cores + 8GB memory**. 
   - In the *Boot disk* section click *Change*, and then **Ubuntu 16.04 LTS** as OS, **SSD** as *disk type* with a **25GB** *size*.
   - In the Firewall section, select **Allow HTTP traffic**.
   - Finally, click the *Create* button to actually create the VM. It will take a few minutes... The process is complete when in the subsequent window a green tick appears near the name of your new machine.
 
   The above configuration looks overkill, but it is useful to install quickly all the necessary software. After the trial, the hardware could be changed whenever pleased according to use.Simply stop the machine 

 - Now, click on the machine name's link, near the green tick, to open the configuration page. 
 - Scroll down and click the link *default* under *Network*. In the following page, we are going to add at least two rules, each requires clicking the button *Add firewall rules*:
    
    - Enter the name **rstudio-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:8787**
    - Enter the name **shiny-server**, as *source filter* choose **Allow from any sources**, in the textbox marked *Allowed protocols and ports* enter **tcp:3838**

- In that same page you can find the *External IP* you'll want to enter later in the browser to connect to your servers. I'll name this IP as **your_server_ip** later in this doc when referring to it.
    
### Working with a Virtual Machine
    
The way these machines usually work is by *SSHing*, or using a terminal window, to send commands, or *SFTPing* to transfer files. 
In both cases, it's possible to use either a browser window, or an application related to the specific OS and hardware at hand. 
For the limited purpose of this demo, we are going to use the Google SSH browser window that you can now open clicking the **SSH** button at the top of the VM instance details page. From now on, all text `marked like this` should be entered in this terminal window.


## Installing the analytics software

### Install R

 - Create a user, home directory and set password and permissions. Substitute *username* with a name that suits you. Also, don't worry if when entering the password nothing happens, Linux doesn't bother to mask characters with asterisks, it just doesn't do anything!
   ```
   sudo useradd username
   sudo mkdir /home/username
   sudo passwd username
   sudo chmod -R 0777 /home/username
   ```

 - Add the CRAN repository to the system file containing the list of *unofficial* Ubuntu repositories: 

   - open the file for editing: ` sudo nano /etc/apt/sources.list `
   - add the following entry: ` deb http://cran.rstudio.com/bin/linux/ubuntu xenial/ `
   - **CTRL+X** to save, **y** to substitute file, **Enter** to exit the nano editor

 - Add the public key of maintaner *Michael Rutter* (or any other one) to secure the Ubuntu *apt* packaging system: 
   ```
   gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
   gpg -a --export E084DAB9 | sudo apt-key add -
   ```
   You should receive back a simple **OK** message at the end. If not, the issue is probably related to a firewall blocking port 11371, and should substitute the first line with the following:
   ```
   gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
   ```

 - Update and upgrade the system:
   ```
   sudo apt-get update && sudo apt-get upgrade
   ```
    
 - install *R*:
   ```
   sudo apt-get install r-base
   ```

### Install RStudio Server

 - Install auxiliary Ubuntu libraries: 
   ```
   sudo apt-get install gdebi-core
   sudo apt-get install libapparmor1
   ```

 - download Rstudio Server installation file: 
   ```
   wget https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-1.0.9-amd64.deb
   ```

 - install Rstudio Server:
   ```
   sudo gdebi rstudio-server-1.0.9-amd64.deb
   ```

It could be useful to visit [this page](http://www.rstudio.com/products/rstudio/download/preview/) to see if any newer version is available, and in that case copy the address for the link *RStudio Server x.yy.zzzz - Ubuntu 12.04+/Debian 8+ (64-bit)*, and change the previous commands accordingly.

RStudio Server should now be set up. To verify this, open the browser and go to **http://your\_server\_ip:8787/** You should see the login form, enter the user and password you created earlier.

### Install Shiny Server
We need first to install at least two *R* packages: *shiny* and *rmarkdown*. In general, using a setup like the one we are building, all *R* packages should be installed as *superuser*, to ensure the existence of a unique *system* library shared among the *normal* user(s) and the *shiny* user. In this way, we avoid duplication and mismatches in versions, preventing malfunctioning.

This is the way we can install a single package: 

`sudo su - -c "R -e \"install.packages('pkg_name', repos = 'http://cran.rstudio.com/')\""`

while multiple packages could be installed from inside *R*, launched as superuser, in the following way :
```
dep.pkg <- c('pkg1_name', 'pkg2_name', ...)
pkgs.not.installed <- dep.pkg[!sapply(dep.pkg, function(p) require(p, character.only = TRUE))]
if( length(pkgs.not.installed) > 0 ) install.packages(pkgs.not.installed, dependencies = TRUE)
```

Let's now go back to the terminal window. 
 - Install first the *shiny* and *rmarkdown* packages:
   ```
   sudo su - -c "R -e \"install.packages('shiny', repos = 'http://cran.rstudio.com/')\""
   sudo su - -c "R -e \"install.packages('rmarkdown', repos = 'http://cran.rstudio.com/')\""
   ```
   
 - download Shiny Server installation file: 

   `wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.4.801-amd64.deb`

 - install Shiny Server: 
   ```
   sudo gdebi shiny-server-1.4.4.801-amd64.deb
   ```

It could be useful to visit [this page](https://www.rstudio.com/products/shiny/download-server/) to see if any newer version is available, and in that case copy the address you find towards the bottom of the page, and change the previous commands accordingly. If you want to find the version of the currently installed version just run `apt-cache showpkg shiny-server` in the terminal.

At this point your newly built Ubuntu machine should have a complete working Shiny Server, that can host both Shiny applications and RMarkdown interactive documents. Try to go to **http://your_server_ip:3838/** and you should be greeted by a fairly basic demo Shiny app and a Rmarkdown document.

By default, the *Shiny Server* is configured to serve applications in the **/srv/shiny-server/** directory owned by the **shiny** user, and listening to port **3838**. This means that ANY Shiny application that is placed at **/srv/shiny-server/app\_name** will be available to EVERYONE at *http://your\_server_ip:3838/app\_name/*. To modify these and other default settings, the configuration file is found at `/etc/shiny-server/shiny-server.conf`. 

Other steps that should be surely taken are:
 - Adding https
 - Adding authentication
 - Changing address

### Install Additional Packages

The power of the *R* system is its possibility to unlimited growth using contributed *packages*. On a Linux machine, some of them require additional software and/or libraries to be installed beforehand. The following is a list of the dependencies needed for the most used packages:
 - devtools: `sudo apt-get install curl && sudo apt-get install libcurl4-gnutls-dev && sudo apt-get install libssl-dev`
 - XML: `sudo apt-get install libxml2-dev`
 - rJava: `sudo apt-get install openjdk-7-* && sudo R CMD javareconf`
 - RMySQL: `sudo apt-get install libmysqlclient-dev`
 - rgdal: `sudo aptitude install libproj-dev` (`sudo apt-get install aptitude` if not working) 
 - rgeos: `sudo aptitude install libgdal-dev`
 - geojsonio (must be installed AFTER previous deps for rgdal & rgeos): `sudo apt-get install libv8-dev`
 - PostGRESql: `sudo apt-get install libpq-dev`

For the purpose of this short demo, we can install only the following packages, which are needed to run the snippets and the app included in this repository. The first line, installing Linux libraries, is needed because of the *devtools* package being included in the list ([*devtools*](http://cran.r-project.org/web/packages/devtools/index.html) is a package development tool, written by RStudio guru [Hadley Wickham](http://twitter.com/hadleywickham), also needed to install packages not deployed by the [official CRAN repository](https://cran.r-project.org/web/views/), but stored only on the Git repository hosting service [GitHub](https://github.com/))
```
sudo apt-get install curl && sudo apt-get install libcurl4-gnutls-dev && sudo apt-get install libssl-dev
sudo su
R
lapply(c('devtools', 'data.table', 'DT', 'ggplot2', 'jsonlite', 'leaflet', 'shinythemes'), install.packages)
q()
exit
```

### Connect RStudio with Git and GitHub

[*GitHub*](https://github.com) is an online repository hosting service based on the version control system [*Git*](https://git-scm.com/), which has also become one of the most popular website where developers and researchers share (and backup!) their code and data. *RStudio* can link to *Git* on the machine and *GitHub* on the web, and provides a simple GUI that eases the hassle to deal with the *Git* shell.

 - Open the Rstudio Server browser window
 - Open **Tools** -> **Global Options** -> **Git/SVN**, and make sure that *Enable version control...* is checked. If not, check it and enter (or browse to) **/usr/bin/git** in the *Git executable* textbox.


## Try the system

To this purpose, let's first download the code that I prepared for you!
 - From the top right menu *Project: (None)* select **New project** -> **Version control** -> **Git**. 
 - In *Repository URL* enter the path of the file you're currently reading: *https://github.com/lvalnegri/presentations-measurecamp09*, the other two fields should get filled automatically. Click *Create Project*. 
 - Now from **File** -> **Open File** choose **R-snippets.R** and run snippets by chunk to see first a map of all Cycle Hire Stations in London, and then some scatterplots by UK regions from last June's EU referendum results.

When you've finished to develop a Shiny app, and want to move it to the server location to deploy it, you simply need to enter in the terminal window the following two commands:
  ```
  sudo mkdir /srv/shiny-server/<APP-NAME>
  sudo cp -R /home/<USER>/<APP-PATH>/app.r /srv/shiny-server/<APP-NAME>/
  ```
where I supposed you want to copy a [single file](http://shiny.rstudio.com/articles/app-formats.html) Shiny app. 

There is a simple example app in my repository, that should be also in your Ubuntu server right now if you've followed my previous commands. We can copy it to the Shiny server directory:
```
  sudo mkdir /srv/shiny-server/mcdemo
  sudo cp -R /home/analytics/presentations-measurecamp09/app.R /srv/shiny-server/mcdemo/
```
where I supposed you called your user **analytics** and you wanted to call your app **mcdemo**. Open now the browser and go to **http://your_server_ip:3838/mcdemo** to see your new Shiny server running the app: a table and a map of all Cycle hire stations in London, with the corresponding number of docks and total hires and average duration of journey since January 2012.


## Where to go next?

 - [Shiny documentation](http://shiny.rstudio.com/articles/)
 - [Shiny tagged entries](https://www.r-bloggers.com/search/shiny) at *R-bloggers* aggregation site
 - [Shiny Google group](https://groups.google.com/forum/#!forum/shiny-discuss)
 - [RStudio Talks](http://www.rstudio.com/resources/webinars/shiny-developer-conference/) from the Shiny Developer Conference
 - [Video from the 2016 useR!](http://channel9.msdn.com/Events/useR-international-R-User-conference/useR2016) International R User conference
 - [RStudio Webinars](http://www.rstudio.com/resources/webinars/)
 - [Stack Overflow](http://stackoverflow.com/tags/r/info)
 - If you enjoy data visualizations, the [htmlwidgets](http://www.htmlwidgets.org/showcase_leaflet.html) package, and [its widgets](http://gallery.htmlwidgets.org/), are a must be known. Also, have a look at the [Building Widgets blog] (http://www.buildingwidgets.com/blog) for some more ideas.

 - [Add Google Analytics to a Shiny app](http://shiny.rstudio.com/articles/google-analytics.html)
 - Have a read at [Mark Edmonson](http://markedmondson.me/) blog


## Credits

 - Santander London Cycles Hire [API](http://api.tfl.gov.uk/bikepoint) and [data](http://cycling.data.tfl.gov.uk) supplied by Transport for London
 - UK Geography lookups provided by [ONS](http://www.ons.gov.uk/methodology/geography/ukgeographies/censusgeography)
 - EU Referendum results thanks to [Electoral Commission](http://www.electoralcommission.org.uk/find-information-by-subject/elections-and-referendums/upcoming-elections-and-referendums/eu-referendum/electorate-and-count-information)


Please, feel free to connect to my profile on [LinkedIn](https://uk.linkedin.com/in/lucavalnegri) or to follow me on [Twitter](http://twitter.com/datamaps)
