# Symfony docker-compose template
Template to host Symfony applications on docker with PHP and MySQL
- Last Symfony version tested: 6.3

This template uses : 
- Last PHP version
- Last nginx version
- Last MySQL version

This template comes with : 
- ✨ PHPCS
- 🛑 PHPStan
- ✅ PHPUnit
- 🚀 Github Workflow to run these tools for each push

## Requirements
To use this template, you need to have these programs installed :
- Docker
- Docker Compose


## Installation
First of all, create folder for your project and go inside it :
```bash
mkdir myproject
cd myproject
```
Now, run this command to download the install script and launch it :
```bash
 wget https://raw.githubusercontent.com/LoickVirot/symfony-docker-environment/feature/install-script/install.sh && bash install.sh
```

## Development
If you want to create some changes in the dist, or the install script, just clone this repository.
You can launch the install script wit h `-l` option to define a dist directory to copy. It's useful when you want to try the install script with your local `dist` folder

For example, in this repository, you can test changes in dist repository with this command:
```bash
mkdir test
cd test
../install.sh -l ../dist
```

To reset test folder and redo install script, use `dev_uninstall.sh` from `test` folder :
```bash
../dev_uninstall.sh
```