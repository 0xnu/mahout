### Mahout

Vagrant running Ubuntu 16.04 LTS (Xenial Xerus) Operating System (OS) for machine learning development.

Installs `Java OpenJDK Version 1.8.0_292`, `Scala 2.11.6`, `Python 2.7.12`, `Apache Hadoop 3.3.1`, `Apache Mahout 0.13.0` and `Apache Spark 3.2.0`.


#### Prerequisite

Install [Vagrant](https://www.vagrantup.com/), [Vagrant Manager](https://www.vagrantmanager.com/) and [VirtualBox](https://www.virtualbox.org/) on your local machine.

```sh
## macOS
brew install --cask vagrant vagrant-manager virtualbox
```


#### Fire Up

```sh
chmod +x vagrant.sh && ./vagrant.sh
```


#### Access Vagrant Machine

```sh
vagrant ssh
sudo su -
```


#### To Do

Fix `hdfs` issue whilst setting up and configuring `Apache Hadoop`


## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.


## License

This project is licensed under the [WTFPL License](LICENSE) - see the file for details.


## Copyright

(c) 2022 [Finbarrs Oketunji](https://finbarrs.eu).