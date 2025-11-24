### PHP development environment with a MySQL database in Docker containers.
Supports applications built with plain PHP, Laravel, Symfony, or other PHP frameworks.  
Block-diagram of a development environment:
<pre>
+-----------------+
| request from    |
| client browser  |
+-----------------+
         |                  +---------------------------+
         V                  | cli service container     |
+-----------------+         | for working with artisan, |
| nginx container |         | Composer, Node.js, npm    |
| port 8080       |         +---------------------------+
+-----------------+                  |
         |                           V
         V                      +-----------------------+
+-------------------+           | "project" directory   |
| php-fpm container |           | with SQLite files     |
| with Xdebug       |---------->| bind mount            |
+-------------------+           +-----------------------+
   |
   |   +----------------------+
   |   | phpmyadmin container |
   |   | port 8090            |
   |   +----------------------+
   |          |
   V          V
+-----------------+     +-------------------------------+
| mysql           |     | "project" database in         |
| container       |---> | php-docker-dev-env-mysql-data |
| port 8306       |     | volume                        |
+-----------------+     +-------------------------------+
</pre>

System requirements:  
linux kernel version 6.17.0-6-generic  
docker engine version 28.5.2  
docker compose version 2.40.3  
unoccupied ports 8080 8090 8306  

[Перейти к Заключению](#заключение)

### Step 1 - building development environment.  

Pull this application from the GitHub repository:
```bash
git clone https://github.com/satnetuser001/php-docker-dev-env.git
```
Rename the root directory ```php-docker-dev-env``` to your project name. This is important because Docker will use this name when building images. Then, navigate to this directory.

Optional step: specify the required versions of PHP, Xdebug, Composer, and Node.js in the ```php-docker-dev-env/.env``` file, otherwise, the latest versions will be used. For the MySQL database, change the root password in the ```php-docker-dev-env/secrets/mysql_root_password.txt``` file. Exclude the ```php-docker-dev-env/secrets``` directory from Git commits by adding it to the ```php-docker-dev-env/.gitignore``` file.

Up all development containers:  
```bash
CUID=$(id -u) CGID=$(id -g) docker compose up -d
```
Note: CUID=$(id -u) CGID=$(id -g) - setting in the images the name ID and group ID of the current user of the host system to set the correct owner for the application files.  

If you need to delete the development environment (all containers and network):
```bash
docker compose down
```
Note: the ```php-docker-dev-env/project``` directory and ```php-docker-dev-env-mysql-data``` volume with the ```project``` database will not be deleted and will remain unchanged.  

### Step 2 - setting up PhpStorm.  

Open the root directory of the project, which is named ```php-docker-dev-env``` by default, in PhpStorm, and configure the following settings:  
- CLI interpreter:
    - Main Menu → Settings or Ctrl+Alt+S
    - Select "PHP" section → Next to "CLI Interpreter" Click ```...```
    - Click ```+``` → Select ```From Docker, Vagrant, VM, WSL, Remote...``` → Check ```Docker Compose```
    - For "Configuration files" select ```./compose.yaml```, for "Service" select ```php-fpm```
    - Click ```OK``` twice
- PHP server:
    - Expand "PHP" section → Select "Servers" → Click ```+```
    - Fill in the fields:
        - Name: ```php-docker-dev-env```
        - Host: ```localhost```
        - Port: ```8080```
        - Debugger: ```Xdebug```
    - Check ```Use path mappings```
    - In mapping settings specify:
        - File/Directory: absolute path to ```php-docker-dev-env/project``` directory
        - Absolute path on the server: ```/project```
    - Click ```Aplly```
- PHP_CodeSniffer
    - Expand "Quality Tools" section → Select "PHP_CodeSniffer"
    - PHP_CodeSniffer inspection: ```on```
    - Next to "Configuration" click ```...```
    - Delete "By default project interpreter" and "System PHP" by clicking ```-```
    - Click ```+``` → Select "php-fpm" → Click ```OK```
    - Fill "PHP_CodeSniffer path" field with ```/usr/local/bin/phpcs```
    - Click ```Validate``` to test — it should display ```OK```
    - Click ```OK```
- PHP-CS-Fixer
    - Select "PHP-CS-Fixer"
    - PHP CS Fixer inspection: ```on```
    - Next to "Configuration" Click ```...```
    - Delete "By default project interpreter" and "System PHP" by clicking ```-```
    - Click ```+``` → Select "php-fpm" → click ```OK```
    - Fill "PHP CS Fixer path" field with ```/usr/local/bin/php-cs-fixer```
    - Click ```Validate``` to test — it should display ```OK```
    - Click ```OK```
- External Formatters:
    - Select "Quality Tools" section → Check ```PHP CS Fixer```
    - Click ```Apply```
- Version Control:
    - Expand the "Version Control" → Select "Directory Mappings"
    - Uncheck ```Enable automatic mapping detection```
    - Remove all paths except absolute path to ```php-docker-dev-env/project```
    - Click ```OK```  
- Database connection:
    - Main Menu → View → Tool Windows → Database
    - Click ```+``` → Data Source → Select ```MySQL```
    - Fill in the fields:
        - Driver: ```MySQL 9```
        - Host: ```localhost```
        - Port: ```8306```
        - User: ```root```
        - Password: ```1077``` value from ```php-docker-dev-env/secrets/mysql_root_password.txt```
        - Database: ```project```
    - Click ```OK```  
- In browser, install ```Xdebug Helper by JetBrains``` extension, and enable Debug mode (green bug icon in toolbar).  

Xdebug logs are saved to ```xdebug/logs``` directory. Xdebug settings are stored in ```xdebug/xdebug.ini``` file.  
Restart the php-fpm container after changing xdebug settings:
```bash
docker restart php-fpm
```  

### Step 3 - development process.

Development directory is ```php-docker-dev-env/project```. Feel free to create something incredible!) To see the result, open in the browser [localhost:8080](http://localhost:8080).  

##### Example of Laravel application setup.
Attach to the ```cli``` service container:  
```bash
docker exec -it cli bash
```
Remove the existing default application:
```bash
rm -rf ./* ./.??*
```
Install a Laravel application using Composer:
```bash
composer create-project --prefer-dist laravel/laravel .
```

##### Setting up a connection between Laravel and MySQL database.  
By default, the latest versions of Laravel use an SQLite database. So it needs to take several next steps to replace the database.
In the ```cli``` service container make a rollback migration for the SQLite database:  
```php
php artisan migrate:rollback
```

In PhpStorm edit ```php-docker-dev-env/project/.env``` file for MySQL database:
```text
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=project
DB_USERNAME=root
DB_PASSWORD=1077
```
Note: DB_PASSWORD must be ```value``` from ```php-docker-dev-env/secrets/mysql_root_password.txt```.

In the ```cli``` service container make a migration for the MySQL database:  
```php
php artisan migrate
```

To see the phpMyAdmin page open in the browser [localhost:8090](http://localhost:8090). Use ```root``` for the "Username" and ```1077``` value from ```php-docker-dev-env/secrets/mysql_root_password.txt``` for the "Password".

### Step 4 - build application image after finishing development.

It is supposed that the production environment architecture is similar to the following block-diagram:
<pre>
+-----------------+
| request from    |
| client browser  |
+-----------------+
         |
         V
+-----------------+
| nginx container |
| port 80         |
+-----------------+
   |                                          +--------------------------+
   |    +---------------+    +-----------+    | "application-1" database |
   |--->| application-1 |--->| mysql-1   |--->| production-mysql-data-1  |
   |    | container     |    | container |    | volume                   |
   .    +---------------+    +-----------+    +--------------------------+
   .
   .                                          +--------------------------+
   |    +---------------+    +-----------+    | "application-N" database |
   |--->| application-N |--->| mysql-N   |--->| production-mysql-data-N  |
        | container     |    | container |    | volume                   |
        +---------------+    +-----------+    +--------------------------+
</pre>

Prepare your application for deployment according to the documentation of the framework you are using.

To build an image for a production environment, exec in ```php-docker-dev-env``` directory:
```bash
docker compose build production
```
Note: remember to rename the built image before push.

If you want to build a stand-alone container from your application, exec in ```php-docker-dev-env``` directory:
```bash
docker compose build stand-alone
```
Note: make sure that the database files, such as SQLite, are located within the application in the ```php-docker-dev-env/project``` directory.  
Note: a stand-alone application image will have only SQLite DBMS, so you need to add the required DBMS to ```php-docker-dev-env/build-app/stand-alone.Dockerfile``` if needed.

## Заключение <a name="заключение"></a>
```bash
docker exec -it cli bash
```
```bash
php artisan migrate:fresh --seed
```
```bash
php artisan l5-swagger:generate
```
```bash
php artisan test --coverage-html=coverage
```