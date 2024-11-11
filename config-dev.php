<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();
$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'mysql';  //É o nome do serviço do docker-compose.yml
$CFG->dbname    = 'moodle'; //Nome do banco criado pelo docker-compose.yml
$CFG->dbuser    = 'moodleuser'; //Nome do usuário criado pelo docker-compose.yml
$CFG->dbpass    = 'moodlepassword'; //Senha usada pelo banco criado pelo docker-compose.yml
$CFG->prefix    = 'm_';
$CFG->dboptions = array (
    'dbpersist' => 0,
    'dbport' => '',
    'dbcollation' => 'utf8mb4_0900_ai_ci',
);
$CFG->dataroot  	        = '/var/moodle_shared/moodledata';
$CFG->localcachedir 	    = '/tmp/';
$CFG->dirroot 		        = '/var/www/html/ava';
$CFG->admin     	        = 'admin';
$CFG->wwwroot   	        = 'http://localhost/ava';
$CFG->forcelogin               = true;
$CFG->preventfilelocking    = true;
$CFG->directorypermissions  = 0777;
$CFG->upgradekey 	        = 'develop';
$CFG->session_update_timemodified_frequency = 50;
$CFG->noemaillever = true;

require_once(__DIR__ . '/lib/setup.php');
