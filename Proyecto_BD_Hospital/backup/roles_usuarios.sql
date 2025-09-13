--
-- PostgreSQL database cluster dump
--

\restrict AdtwSpr9GVQiLP3leQ9cmcYc3fuVvVv4GfllapMTjcFOYh8obqukMmJCUPLmKRa

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE hospital;
ALTER ROLE hospital WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:rCdeSmqCoG2C6TO6aak6JA==$KRidFNo1iPj3lWwUjIKuj5W1kScuIQhYOoUj98eE4OI=:iu6SPKZJNQPj6nObiDLJjbloVTe+83YYl38//XMhUmY=';
CREATE ROLE usuario_admin;
ALTER ROLE usuario_admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:XguL10dGCyFh6KF+de6f8A==$F2eTAXps1M26kAPdKQasgsiBpp23eS33C+yRTalJ1EQ=:wlgSb1KxUM3HZnduilUGoYIf6cYmqGEYXsRbJVgQsuQ=';
CREATE ROLE usuario_auditoria;
ALTER ROLE usuario_auditoria WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:P0TrVyK4ZeV+ZWy4UvxhNw==$eN+//l5qNEQzn9UfT2xjVa3TpP3ZkmCnfL8oFOpAeko=:/h4bJOC/VHTP0Xv/BJhndiFovPd0/p0wGYqsraFyA1w=';

--
-- User Configurations
--






\unrestrict AdtwSpr9GVQiLP3leQ9cmcYc3fuVvVv4GfllapMTjcFOYh8obqukMmJCUPLmKRa

--
-- PostgreSQL database cluster dump complete
--

