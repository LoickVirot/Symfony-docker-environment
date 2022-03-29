# Symfony docker-compose template
Template to host Symfony applications on docker with PHP and MySQL
- Last Symfony version tested: 6.0
 
## Installation
### Environment installation
Clone repository.
```bash
git clone git@github.com:LoickVirot/Symfony-docker-environment.git <project_name>
```

Create environment file. You can edit the `.env` file to adapt it to your system.  
```bash
cp .env.example .env
```

Now, you can run docker containers.
```bash
docker-compose up -d
```
### Create new symfony project
In the php container, run composer command to create symfony project. You can have more information about [Symfony installation in this page.](https://symfony.com/doc/current/setup.html)
```bash
docker-compose exec symfony composer create-project symfony/skeleton .
```

> If there is a `website-skeleton` folder in your `www`directory, move **all** content from `website-skeleton` folder project to `www` folder.

If everything is well setted up, you can see the symfony homepage in your browser : [http://localhost/](http://localhost)

When all project is setted up, change host's permissions to be able to change code.
```bash
sudo chown -R $(id -un):$(id -gn) www
```

## Configuration
Here is the .env parameters you can customize :
Variable name|Default|Description 
---|---|---
APP_PORT|80|Port to access to the symfony project.
MYSQL_PORT|3306|Port to access to the database.