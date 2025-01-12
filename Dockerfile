FROM ubuntu:latest

RUN apt-get -qq update \
# Run on a separate line b/c of the env variable which prevents docker builds from requiring interaction
    &&  DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -qq --no-install-recommends install -y tzdata \
    && apt-get -qq --no-install-recommends install -y vim \
    && apt-get -qq --no-install-recommends install -y apache2 \
    && apt-get -qq --no-install-recommends install -y libapache2-mod-php \
    && apt-get -qq --no-install-recommends install -y iputils-ping \
    && apt-get -qq --no-install-recommends install -y openssh-server \
    && apt-get -qq --no-install-recommends install -y python3 \
    && apt-get -qq --no-install-recommends install -y python3-pip \
    && apt-get -qq --no-install-recommends install -y cron \
    && apt-get -qq --no-install-recommends install -y emacs \
    && apt-get -qq --no-install-recommends install -y nano \
    && apt-get -qq --no-install-recommends install -y sudo \
    && apt-get -qq --no-install-recommends install -y curl wget \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite
COPY cronjob/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --require-hashes -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt
COPY web/ /var/www/html/
RUN mv /var/www/html/apache_config.conf /etc/apache2/sites-available/000-default.conf
RUN chmod a+r /var/www/html/* /var/www/html/.*

# Add the flag for getting root
ADD flag.txt /root/

RUN useradd --shell /bin/bash -m jacob
RUN mkdir /home/jacob/.ssh/
RUN mkdir /root/.ssh/
RUN ssh-keygen -t rsa -N '' -C 'jacob' -f /home/jacob/.ssh/id_rsa
RUN chown -R jacob:jacob /home/jacob/.ssh/
RUN chmod -R 755 /home/jacob/
RUN cp /home/jacob/.ssh/id_rsa.pub /home/jacob/.ssh/authorized_keys

# Taken from https://stackoverflow.com/a/61738823
# Configure SSHD.
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd
RUN bash -c 'install -m755 <(printf "#!/bin/sh\nexit 0") /usr/sbin/policy-rc.d'
RUN ex +'%s/^#\zeListenAddress/\1/g' -scwq /etc/ssh/sshd_config
RUN ex +'%s/^#\zeHostKey .*ssh_host_.*_key/\1/g' -scwq /etc/ssh/sshd_config
# GCE doesn't let us remap ports, so we have to map sshd to port 2222 here
RUN ex +'%s/^#Port 22/Port 2222/g' -scwq /etc/ssh/sshd_config
RUN RUNLEVEL=1 dpkg-reconfigure openssh-server
RUN ssh-keygen -A -v
RUN update-rc.d ssh defaults

# Set up vulnerable cron job
RUN mkdir /protos
RUN mkdir /cronjob
COPY cronjob/update_file_job.py /cronjob/
COPY cronjob/update_file_pb2.py /cronjob/
COPY cronjob/update_file.proto /protos/
COPY cronjob/protos/best_hacker.textproto /protos/
COPY cronjob/update_files /etc/cron.d/
RUN chmod 644 /etc/cron.d/update_files
RUN touch /var/log/cron.log # Create crontab logfile
# Ensure the lowpriv user can write protos and read the cronjob directory
RUN chown -R jacob:jacob  /protos
RUN chmod -R 775 /protos
RUN chmod -R 555 /cronjob
# Since we're starting a bunch of services, we run them from a script
RUN mkdir /services
COPY start_service.sh /services/
RUN chmod +x /services/start_service.sh

EXPOSE 80
EXPOSE 2222

CMD ["bash", "/services/start_service.sh"]
