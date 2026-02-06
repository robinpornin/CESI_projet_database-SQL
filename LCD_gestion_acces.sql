create user if not exists 'admin'@'localhost' identified by 'admin_mdp' ;
grant all privileges on bdd_grp3.* to 'admin'@'localhost' ;

create user if not exists 'user'@'localhost' identified by 'user_mdp' ;
grant select on bdd_grp3.* to 'user'@'localhost' ;

flush privileges ;
