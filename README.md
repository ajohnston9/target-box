# Practical Pentesting: Vulnerable Target

This is a basic target for the internal "Practical Pentesting" class aimed at introducing penetration testing to engineers. This repo contains
the resources to contain a vulnerable target used for the hands-on portion of the class.

## Running

Build the container

```
docker build -t vulnerable-target .
```

Execute the container

```
docker run -p2222:2222 -p80:80 vulnerable-target
```

