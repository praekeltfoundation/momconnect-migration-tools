--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: jason
--

CREATE TABLE contacts (
    key character varying(32) NOT NULL,
    cursor character varying(64),
    msisdn character varying(255),
    json json
);


ALTER TABLE contacts OWNER TO jason;

--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: jason
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (key);


--
-- Name: msisdn_index; Type: INDEX; Schema: public; Owner: jason
--

CREATE INDEX msisdn_index ON contacts USING btree (msisdn);


--
-- Name: public; Type: ACL; Schema: -; Owner: jason
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM jason;
GRANT ALL ON SCHEMA public TO jason;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

