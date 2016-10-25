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
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);


ALTER TABLE auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_group_permissions_id_seq OWNED BY auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone NOT NULL,
    is_superuser boolean NOT NULL,
    username character varying(30) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    email character varying(75) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE auth_user OWNER TO postgres;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE auth_user_groups OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_groups_id_seq OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_groups_id_seq OWNED BY auth_user_groups.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE auth_user_user_permissions OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE auth_user_user_permissions_id_seq OWNED BY auth_user_user_permissions.id;


--
-- Name: authtoken_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE authtoken_token (
    key character varying(40) NOT NULL,
    user_id integer NOT NULL,
    created timestamp with time zone NOT NULL
);


ALTER TABLE authtoken_token OWNER TO postgres;

--
-- Name: celery_taskmeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE celery_taskmeta (
    id integer NOT NULL,
    task_id character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    result text,
    date_done timestamp with time zone NOT NULL,
    traceback text,
    hidden boolean NOT NULL,
    meta text
);


ALTER TABLE celery_taskmeta OWNER TO postgres;

--
-- Name: celery_taskmeta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE celery_taskmeta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE celery_taskmeta_id_seq OWNER TO postgres;

--
-- Name: celery_taskmeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE celery_taskmeta_id_seq OWNED BY celery_taskmeta.id;


--
-- Name: celery_tasksetmeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE celery_tasksetmeta (
    id integer NOT NULL,
    taskset_id character varying(255) NOT NULL,
    result text NOT NULL,
    date_done timestamp with time zone NOT NULL,
    hidden boolean NOT NULL
);


ALTER TABLE celery_tasksetmeta OWNER TO postgres;

--
-- Name: celery_tasksetmeta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE celery_tasksetmeta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE celery_tasksetmeta_id_seq OWNER TO postgres;

--
-- Name: celery_tasksetmeta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE celery_tasksetmeta_id_seq OWNED BY celery_tasksetmeta.id;


--
-- Name: controlinterface_dashboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_dashboard (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    dashboard_type character varying(10) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE controlinterface_dashboard OWNER TO postgres;

--
-- Name: controlinterface_dashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_dashboard_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_dashboard_id_seq OWNER TO postgres;

--
-- Name: controlinterface_dashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_dashboard_id_seq OWNED BY controlinterface_dashboard.id;


--
-- Name: controlinterface_dashboard_widgets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_dashboard_widgets (
    id integer NOT NULL,
    dashboard_id integer NOT NULL,
    widget_id integer NOT NULL
);


ALTER TABLE controlinterface_dashboard_widgets OWNER TO postgres;

--
-- Name: controlinterface_dashboard_widgets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_dashboard_widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_dashboard_widgets_id_seq OWNER TO postgres;

--
-- Name: controlinterface_dashboard_widgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_dashboard_widgets_id_seq OWNED BY controlinterface_dashboard_widgets.id;


--
-- Name: controlinterface_userdashboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_userdashboard (
    id integer NOT NULL,
    user_id integer NOT NULL,
    default_dashboard_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE controlinterface_userdashboard OWNER TO postgres;

--
-- Name: controlinterface_userdashboard_dashboards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_userdashboard_dashboards (
    id integer NOT NULL,
    userdashboard_id integer NOT NULL,
    dashboard_id integer NOT NULL
);


ALTER TABLE controlinterface_userdashboard_dashboards OWNER TO postgres;

--
-- Name: controlinterface_userdashboard_dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_userdashboard_dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_userdashboard_dashboards_id_seq OWNER TO postgres;

--
-- Name: controlinterface_userdashboard_dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_userdashboard_dashboards_id_seq OWNED BY controlinterface_userdashboard_dashboards.id;


--
-- Name: controlinterface_userdashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_userdashboard_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_userdashboard_id_seq OWNER TO postgres;

--
-- Name: controlinterface_userdashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_userdashboard_id_seq OWNED BY controlinterface_userdashboard.id;


--
-- Name: controlinterface_widget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_widget (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    type_of character varying(10) NOT NULL,
    data_from character varying(20) NOT NULL,
    "interval" character varying(20) NOT NULL,
    nulls character varying(20),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE controlinterface_widget OWNER TO postgres;

--
-- Name: controlinterface_widget_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_widget_data (
    id integer NOT NULL,
    widget_id integer NOT NULL,
    widgetdata_id integer NOT NULL
);


ALTER TABLE controlinterface_widget_data OWNER TO postgres;

--
-- Name: controlinterface_widget_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_widget_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_widget_data_id_seq OWNER TO postgres;

--
-- Name: controlinterface_widget_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_widget_data_id_seq OWNED BY controlinterface_widget_data.id;


--
-- Name: controlinterface_widget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_widget_id_seq OWNER TO postgres;

--
-- Name: controlinterface_widget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_widget_id_seq OWNED BY controlinterface_widget.id;


--
-- Name: controlinterface_widgetdata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE controlinterface_widgetdata (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    key character varying(200) NOT NULL,
    source character varying(10) NOT NULL,
    data_type character varying(10) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE controlinterface_widgetdata OWNER TO postgres;

--
-- Name: controlinterface_widgetdata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controlinterface_widgetdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controlinterface_widgetdata_id_seq OWNER TO postgres;

--
-- Name: controlinterface_widgetdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controlinterface_widgetdata_id_seq OWNED BY controlinterface_widgetdata.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    content_type_id integer,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_admin_log_id_seq OWNED BY django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE django_content_type (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_content_type_id_seq OWNED BY django_content_type.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE django_session OWNER TO postgres;

--
-- Name: django_site; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE django_site (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE django_site OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE django_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE django_site_id_seq OWNER TO postgres;

--
-- Name: django_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE django_site_id_seq OWNED BY django_site.id;


--
-- Name: djcelery_crontabschedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_crontabschedule (
    id integer NOT NULL,
    minute character varying(64) NOT NULL,
    hour character varying(64) NOT NULL,
    day_of_week character varying(64) NOT NULL,
    day_of_month character varying(64) NOT NULL,
    month_of_year character varying(64) NOT NULL
);


ALTER TABLE djcelery_crontabschedule OWNER TO postgres;

--
-- Name: djcelery_crontabschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE djcelery_crontabschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE djcelery_crontabschedule_id_seq OWNER TO postgres;

--
-- Name: djcelery_crontabschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE djcelery_crontabschedule_id_seq OWNED BY djcelery_crontabschedule.id;


--
-- Name: djcelery_intervalschedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_intervalschedule (
    id integer NOT NULL,
    every integer NOT NULL,
    period character varying(24) NOT NULL
);


ALTER TABLE djcelery_intervalschedule OWNER TO postgres;

--
-- Name: djcelery_intervalschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE djcelery_intervalschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE djcelery_intervalschedule_id_seq OWNER TO postgres;

--
-- Name: djcelery_intervalschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE djcelery_intervalschedule_id_seq OWNED BY djcelery_intervalschedule.id;


--
-- Name: djcelery_periodictask; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_periodictask (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    task character varying(200) NOT NULL,
    interval_id integer,
    crontab_id integer,
    args text NOT NULL,
    kwargs text NOT NULL,
    queue character varying(200),
    exchange character varying(200),
    routing_key character varying(200),
    expires timestamp with time zone,
    enabled boolean NOT NULL,
    last_run_at timestamp with time zone,
    total_run_count integer NOT NULL,
    date_changed timestamp with time zone NOT NULL,
    description text NOT NULL,
    CONSTRAINT djcelery_periodictask_total_run_count_check CHECK ((total_run_count >= 0))
);


ALTER TABLE djcelery_periodictask OWNER TO postgres;

--
-- Name: djcelery_periodictask_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE djcelery_periodictask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE djcelery_periodictask_id_seq OWNER TO postgres;

--
-- Name: djcelery_periodictask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE djcelery_periodictask_id_seq OWNED BY djcelery_periodictask.id;


--
-- Name: djcelery_periodictasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_periodictasks (
    ident smallint NOT NULL,
    last_update timestamp with time zone NOT NULL
);


ALTER TABLE djcelery_periodictasks OWNER TO postgres;

--
-- Name: djcelery_taskstate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_taskstate (
    id integer NOT NULL,
    state character varying(64) NOT NULL,
    task_id character varying(36) NOT NULL,
    name character varying(200),
    tstamp timestamp with time zone NOT NULL,
    args text,
    kwargs text,
    eta timestamp with time zone,
    expires timestamp with time zone,
    result text,
    traceback text,
    runtime double precision,
    retries integer NOT NULL,
    worker_id integer,
    hidden boolean NOT NULL
);


ALTER TABLE djcelery_taskstate OWNER TO postgres;

--
-- Name: djcelery_taskstate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE djcelery_taskstate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE djcelery_taskstate_id_seq OWNER TO postgres;

--
-- Name: djcelery_taskstate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE djcelery_taskstate_id_seq OWNED BY djcelery_taskstate.id;


--
-- Name: djcelery_workerstate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE djcelery_workerstate (
    id integer NOT NULL,
    hostname character varying(255) NOT NULL,
    last_heartbeat timestamp with time zone
);


ALTER TABLE djcelery_workerstate OWNER TO postgres;

--
-- Name: djcelery_workerstate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE djcelery_workerstate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE djcelery_workerstate_id_seq OWNER TO postgres;

--
-- Name: djcelery_workerstate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE djcelery_workerstate_id_seq OWNED BY djcelery_workerstate.id;


--
-- Name: nursereg_nursereg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE nursereg_nursereg (
    id integer NOT NULL,
    cmsisdn character varying(255) NOT NULL,
    dmsisdn character varying(255),
    rmsisdn character varying(255),
    faccode character varying(100) NOT NULL,
    id_type character varying(8),
    id_no character varying(100),
    passport_origin character varying(100),
    dob date,
    nurse_source_id integer NOT NULL,
    persal_no integer,
    opted_out boolean NOT NULL,
    optout_reason character varying(100),
    optout_count integer NOT NULL,
    sanc_reg_no integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE nursereg_nursereg OWNER TO postgres;

--
-- Name: nursereg_nursereg_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE nursereg_nursereg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE nursereg_nursereg_id_seq OWNER TO postgres;

--
-- Name: nursereg_nursereg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE nursereg_nursereg_id_seq OWNED BY nursereg_nursereg.id;


--
-- Name: nursereg_nursesource; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE nursereg_nursesource (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE nursereg_nursesource OWNER TO postgres;

--
-- Name: nursereg_nursesource_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE nursereg_nursesource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE nursereg_nursesource_id_seq OWNER TO postgres;

--
-- Name: nursereg_nursesource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE nursereg_nursesource_id_seq OWNED BY nursereg_nursesource.id;


--
-- Name: registration_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE registration_registration (
    id integer NOT NULL,
    hcw_msisdn character varying(255),
    mom_msisdn character varying(255) NOT NULL,
    mom_id_type character varying(8) NOT NULL,
    mom_lang character varying(3) NOT NULL,
    mom_edd date,
    mom_id_no character varying(100),
    mom_dob date,
    clinic_code character varying(100),
    authority character varying(8) NOT NULL,
    source_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    mom_passport_origin character varying(100),
    consent boolean
);


ALTER TABLE registration_registration OWNER TO postgres;

--
-- Name: registration_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE registration_registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE registration_registration_id_seq OWNER TO postgres;

--
-- Name: registration_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE registration_registration_id_seq OWNED BY registration_registration.id;


--
-- Name: registration_source; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE registration_source (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE registration_source OWNER TO postgres;

--
-- Name: registration_source_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE registration_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE registration_source_id_seq OWNER TO postgres;

--
-- Name: registration_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE registration_source_id_seq OWNED BY registration_source.id;


--
-- Name: servicerating_contact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicerating_contact (
    id integer NOT NULL,
    conversation_id integer NOT NULL,
    key character varying(43) NOT NULL,
    value text,
    msisdn character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE servicerating_contact OWNER TO postgres;

--
-- Name: servicerating_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servicerating_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servicerating_contact_id_seq OWNER TO postgres;

--
-- Name: servicerating_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servicerating_contact_id_seq OWNED BY servicerating_contact.id;


--
-- Name: servicerating_conversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicerating_conversation (
    id integer NOT NULL,
    user_account_id integer NOT NULL,
    key character varying(43) NOT NULL,
    name character varying(200) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE servicerating_conversation OWNER TO postgres;

--
-- Name: servicerating_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servicerating_conversation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servicerating_conversation_id_seq OWNER TO postgres;

--
-- Name: servicerating_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servicerating_conversation_id_seq OWNED BY servicerating_conversation.id;


--
-- Name: servicerating_extra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicerating_extra (
    id integer NOT NULL,
    contact_id integer NOT NULL,
    key character varying(200) NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE servicerating_extra OWNER TO postgres;

--
-- Name: servicerating_extra_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servicerating_extra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servicerating_extra_id_seq OWNER TO postgres;

--
-- Name: servicerating_extra_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servicerating_extra_id_seq OWNED BY servicerating_extra.id;


--
-- Name: servicerating_response; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicerating_response (
    id integer NOT NULL,
    contact_id integer NOT NULL,
    key character varying(200) NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE servicerating_response OWNER TO postgres;

--
-- Name: servicerating_response_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servicerating_response_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servicerating_response_id_seq OWNER TO postgres;

--
-- Name: servicerating_response_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servicerating_response_id_seq OWNED BY servicerating_response.id;


--
-- Name: servicerating_useraccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE servicerating_useraccount (
    id integer NOT NULL,
    key character varying(43) NOT NULL,
    name character varying(200) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE servicerating_useraccount OWNER TO postgres;

--
-- Name: servicerating_useraccount_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE servicerating_useraccount_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE servicerating_useraccount_id_seq OWNER TO postgres;

--
-- Name: servicerating_useraccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE servicerating_useraccount_id_seq OWNED BY servicerating_useraccount.id;


--
-- Name: snappybouncer_conversation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE snappybouncer_conversation (
    id integer NOT NULL,
    user_account_id integer NOT NULL,
    key character varying(43) NOT NULL,
    name character varying(200) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE snappybouncer_conversation OWNER TO postgres;

--
-- Name: snappybouncer_conversation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE snappybouncer_conversation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE snappybouncer_conversation_id_seq OWNER TO postgres;

--
-- Name: snappybouncer_conversation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE snappybouncer_conversation_id_seq OWNED BY snappybouncer_conversation.id;


--
-- Name: snappybouncer_ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE snappybouncer_ticket (
    id integer NOT NULL,
    conversation_id integer NOT NULL,
    support_nonce character varying(43),
    support_id integer,
    message text NOT NULL,
    response text,
    contact_key character varying(43) NOT NULL,
    msisdn character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    tag character varying(30),
    operator integer,
    faccode integer
);


ALTER TABLE snappybouncer_ticket OWNER TO postgres;

--
-- Name: snappybouncer_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE snappybouncer_ticket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE snappybouncer_ticket_id_seq OWNER TO postgres;

--
-- Name: snappybouncer_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE snappybouncer_ticket_id_seq OWNED BY snappybouncer_ticket.id;


--
-- Name: snappybouncer_useraccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE snappybouncer_useraccount (
    id integer NOT NULL,
    key character varying(43) NOT NULL,
    name character varying(200) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE snappybouncer_useraccount OWNER TO postgres;

--
-- Name: snappybouncer_useraccount_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE snappybouncer_useraccount_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE snappybouncer_useraccount_id_seq OWNER TO postgres;

--
-- Name: snappybouncer_useraccount_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE snappybouncer_useraccount_id_seq OWNED BY snappybouncer_useraccount.id;


--
-- Name: south_migrationhistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE south_migrationhistory (
    id integer NOT NULL,
    app_name character varying(255) NOT NULL,
    migration character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE south_migrationhistory OWNER TO postgres;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE south_migrationhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE south_migrationhistory_id_seq OWNER TO postgres;

--
-- Name: south_migrationhistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE south_migrationhistory_id_seq OWNED BY south_migrationhistory.id;


--
-- Name: subscription_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE subscription_message (
    id integer NOT NULL,
    message_set_id integer NOT NULL,
    sequence_number integer NOT NULL,
    lang character varying(3) NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    category character varying(20)
);


ALTER TABLE subscription_message OWNER TO postgres;

--
-- Name: subscription_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscription_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscription_message_id_seq OWNER TO postgres;

--
-- Name: subscription_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscription_message_id_seq OWNED BY subscription_message.id;


--
-- Name: subscription_messageset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE subscription_messageset (
    id integer NOT NULL,
    short_name character varying(20) NOT NULL,
    notes text,
    next_set_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    default_schedule_id integer NOT NULL,
    conversation_key character varying(255)
);


ALTER TABLE subscription_messageset OWNER TO postgres;

--
-- Name: subscription_messageset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscription_messageset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscription_messageset_id_seq OWNER TO postgres;

--
-- Name: subscription_messageset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscription_messageset_id_seq OWNED BY subscription_messageset.id;


--
-- Name: subscription_subscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE subscription_subscription (
    id integer NOT NULL,
    user_account character varying(36) NOT NULL,
    contact_key character varying(36) NOT NULL,
    to_addr character varying(255) NOT NULL,
    message_set_id integer NOT NULL,
    next_sequence_number integer NOT NULL,
    lang character varying(3) NOT NULL,
    active boolean NOT NULL,
    completed boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    schedule_id integer NOT NULL,
    process_status integer NOT NULL
);


ALTER TABLE subscription_subscription OWNER TO postgres;

--
-- Name: subscription_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subscription_subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE subscription_subscription_id_seq OWNER TO postgres;

--
-- Name: subscription_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subscription_subscription_id_seq OWNED BY subscription_subscription.id;


--
-- Name: tastypie_apiaccess; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tastypie_apiaccess (
    id integer NOT NULL,
    identifier character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    request_method character varying(10) NOT NULL,
    accessed integer NOT NULL,
    CONSTRAINT tastypie_apiaccess_accessed_check CHECK ((accessed >= 0))
);


ALTER TABLE tastypie_apiaccess OWNER TO postgres;

--
-- Name: tastypie_apiaccess_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tastypie_apiaccess_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tastypie_apiaccess_id_seq OWNER TO postgres;

--
-- Name: tastypie_apiaccess_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tastypie_apiaccess_id_seq OWNED BY tastypie_apiaccess.id;


--
-- Name: tastypie_apikey; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tastypie_apikey (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying(256) NOT NULL,
    created timestamp with time zone NOT NULL
);


ALTER TABLE tastypie_apikey OWNER TO postgres;

--
-- Name: tastypie_apikey_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tastypie_apikey_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tastypie_apikey_id_seq OWNER TO postgres;

--
-- Name: tastypie_apikey_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tastypie_apikey_id_seq OWNED BY tastypie_apikey.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('auth_group_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups ALTER COLUMN id SET DEFAULT nextval('auth_user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('auth_user_user_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_taskmeta ALTER COLUMN id SET DEFAULT nextval('celery_taskmeta_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_tasksetmeta ALTER COLUMN id SET DEFAULT nextval('celery_tasksetmeta_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard ALTER COLUMN id SET DEFAULT nextval('controlinterface_dashboard_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard_widgets ALTER COLUMN id SET DEFAULT nextval('controlinterface_dashboard_widgets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard ALTER COLUMN id SET DEFAULT nextval('controlinterface_userdashboard_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard_dashboards ALTER COLUMN id SET DEFAULT nextval('controlinterface_userdashboard_dashboards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget ALTER COLUMN id SET DEFAULT nextval('controlinterface_widget_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget_data ALTER COLUMN id SET DEFAULT nextval('controlinterface_widget_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widgetdata ALTER COLUMN id SET DEFAULT nextval('controlinterface_widgetdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log ALTER COLUMN id SET DEFAULT nextval('django_admin_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_content_type ALTER COLUMN id SET DEFAULT nextval('django_content_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_site ALTER COLUMN id SET DEFAULT nextval('django_site_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_crontabschedule ALTER COLUMN id SET DEFAULT nextval('djcelery_crontabschedule_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_intervalschedule ALTER COLUMN id SET DEFAULT nextval('djcelery_intervalschedule_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictask ALTER COLUMN id SET DEFAULT nextval('djcelery_periodictask_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_taskstate ALTER COLUMN id SET DEFAULT nextval('djcelery_taskstate_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_workerstate ALTER COLUMN id SET DEFAULT nextval('djcelery_workerstate_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursereg ALTER COLUMN id SET DEFAULT nextval('nursereg_nursereg_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursesource ALTER COLUMN id SET DEFAULT nextval('nursereg_nursesource_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_registration ALTER COLUMN id SET DEFAULT nextval('registration_registration_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_source ALTER COLUMN id SET DEFAULT nextval('registration_source_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_contact ALTER COLUMN id SET DEFAULT nextval('servicerating_contact_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_conversation ALTER COLUMN id SET DEFAULT nextval('servicerating_conversation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_extra ALTER COLUMN id SET DEFAULT nextval('servicerating_extra_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_response ALTER COLUMN id SET DEFAULT nextval('servicerating_response_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_useraccount ALTER COLUMN id SET DEFAULT nextval('servicerating_useraccount_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_conversation ALTER COLUMN id SET DEFAULT nextval('snappybouncer_conversation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_ticket ALTER COLUMN id SET DEFAULT nextval('snappybouncer_ticket_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_useraccount ALTER COLUMN id SET DEFAULT nextval('snappybouncer_useraccount_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY south_migrationhistory ALTER COLUMN id SET DEFAULT nextval('south_migrationhistory_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_message ALTER COLUMN id SET DEFAULT nextval('subscription_message_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_messageset ALTER COLUMN id SET DEFAULT nextval('subscription_messageset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_subscription ALTER COLUMN id SET DEFAULT nextval('subscription_subscription_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apiaccess ALTER COLUMN id SET DEFAULT nextval('tastypie_apiaccess_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apikey ALTER COLUMN id SET DEFAULT nextval('tastypie_apikey_id_seq'::regclass);


--
-- Name: auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions_group_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_key UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission_content_type_id_codename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_key UNIQUE (content_type_id, codename);


--
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups_user_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_key UNIQUE (user_id, group_id);


--
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions_user_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id);


--
-- Name: auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: authtoken_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authtoken_token
    ADD CONSTRAINT authtoken_token_pkey PRIMARY KEY (key);


--
-- Name: authtoken_token_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authtoken_token
    ADD CONSTRAINT authtoken_token_user_id_key UNIQUE (user_id);


--
-- Name: celery_taskmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_taskmeta
    ADD CONSTRAINT celery_taskmeta_pkey PRIMARY KEY (id);


--
-- Name: celery_taskmeta_task_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_taskmeta
    ADD CONSTRAINT celery_taskmeta_task_id_key UNIQUE (task_id);


--
-- Name: celery_tasksetmeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_tasksetmeta
    ADD CONSTRAINT celery_tasksetmeta_pkey PRIMARY KEY (id);


--
-- Name: celery_tasksetmeta_taskset_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY celery_tasksetmeta
    ADD CONSTRAINT celery_tasksetmeta_taskset_id_key UNIQUE (taskset_id);


--
-- Name: controlinterface_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard
    ADD CONSTRAINT controlinterface_dashboard_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_dashboard_w_dashboard_id_3632571f7dba3c20_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard_widgets
    ADD CONSTRAINT controlinterface_dashboard_w_dashboard_id_3632571f7dba3c20_uniq UNIQUE (dashboard_id, widget_id);


--
-- Name: controlinterface_dashboard_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard_widgets
    ADD CONSTRAINT controlinterface_dashboard_widgets_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_userdas_userdashboard_id_64c4d8a28a35831a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard_dashboards
    ADD CONSTRAINT controlinterface_userdas_userdashboard_id_64c4d8a28a35831a_uniq UNIQUE (userdashboard_id, dashboard_id);


--
-- Name: controlinterface_userdashboard_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard_dashboards
    ADD CONSTRAINT controlinterface_userdashboard_dashboards_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_userdashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard
    ADD CONSTRAINT controlinterface_userdashboard_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_userdashboard_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard
    ADD CONSTRAINT controlinterface_userdashboard_user_id_key UNIQUE (user_id);


--
-- Name: controlinterface_widget_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget_data
    ADD CONSTRAINT controlinterface_widget_data_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_widget_data_widget_id_7a3a6311ae115e30_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget_data
    ADD CONSTRAINT controlinterface_widget_data_widget_id_7a3a6311ae115e30_uniq UNIQUE (widget_id, widgetdata_id);


--
-- Name: controlinterface_widget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget
    ADD CONSTRAINT controlinterface_widget_pkey PRIMARY KEY (id);


--
-- Name: controlinterface_widgetdata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widgetdata
    ADD CONSTRAINT controlinterface_widgetdata_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type_app_label_model_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_key UNIQUE (app_label, model);


--
-- Name: django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: django_site_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_site
    ADD CONSTRAINT django_site_pkey PRIMARY KEY (id);


--
-- Name: djcelery_crontabschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_crontabschedule
    ADD CONSTRAINT djcelery_crontabschedule_pkey PRIMARY KEY (id);


--
-- Name: djcelery_intervalschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_intervalschedule
    ADD CONSTRAINT djcelery_intervalschedule_pkey PRIMARY KEY (id);


--
-- Name: djcelery_periodictask_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictask
    ADD CONSTRAINT djcelery_periodictask_name_key UNIQUE (name);


--
-- Name: djcelery_periodictask_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictask
    ADD CONSTRAINT djcelery_periodictask_pkey PRIMARY KEY (id);


--
-- Name: djcelery_periodictasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictasks
    ADD CONSTRAINT djcelery_periodictasks_pkey PRIMARY KEY (ident);


--
-- Name: djcelery_taskstate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_taskstate
    ADD CONSTRAINT djcelery_taskstate_pkey PRIMARY KEY (id);


--
-- Name: djcelery_taskstate_task_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_taskstate
    ADD CONSTRAINT djcelery_taskstate_task_id_key UNIQUE (task_id);


--
-- Name: djcelery_workerstate_hostname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_workerstate
    ADD CONSTRAINT djcelery_workerstate_hostname_key UNIQUE (hostname);


--
-- Name: djcelery_workerstate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_workerstate
    ADD CONSTRAINT djcelery_workerstate_pkey PRIMARY KEY (id);


--
-- Name: nursereg_nursereg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursereg
    ADD CONSTRAINT nursereg_nursereg_pkey PRIMARY KEY (id);


--
-- Name: nursereg_nursesource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursesource
    ADD CONSTRAINT nursereg_nursesource_pkey PRIMARY KEY (id);


--
-- Name: registration_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_registration
    ADD CONSTRAINT registration_registration_pkey PRIMARY KEY (id);


--
-- Name: registration_source_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_source
    ADD CONSTRAINT registration_source_pkey PRIMARY KEY (id);


--
-- Name: servicerating_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_contact
    ADD CONSTRAINT servicerating_contact_pkey PRIMARY KEY (id);


--
-- Name: servicerating_conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_conversation
    ADD CONSTRAINT servicerating_conversation_pkey PRIMARY KEY (id);


--
-- Name: servicerating_extra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_extra
    ADD CONSTRAINT servicerating_extra_pkey PRIMARY KEY (id);


--
-- Name: servicerating_response_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_response
    ADD CONSTRAINT servicerating_response_pkey PRIMARY KEY (id);


--
-- Name: servicerating_useraccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_useraccount
    ADD CONSTRAINT servicerating_useraccount_pkey PRIMARY KEY (id);


--
-- Name: snappybouncer_conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_conversation
    ADD CONSTRAINT snappybouncer_conversation_pkey PRIMARY KEY (id);


--
-- Name: snappybouncer_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_ticket
    ADD CONSTRAINT snappybouncer_ticket_pkey PRIMARY KEY (id);


--
-- Name: snappybouncer_useraccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_useraccount
    ADD CONSTRAINT snappybouncer_useraccount_pkey PRIMARY KEY (id);


--
-- Name: south_migrationhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY south_migrationhistory
    ADD CONSTRAINT south_migrationhistory_pkey PRIMARY KEY (id);


--
-- Name: subscription_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_message
    ADD CONSTRAINT subscription_message_pkey PRIMARY KEY (id);


--
-- Name: subscription_messageset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_messageset
    ADD CONSTRAINT subscription_messageset_pkey PRIMARY KEY (id);


--
-- Name: subscription_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_subscription
    ADD CONSTRAINT subscription_subscription_pkey PRIMARY KEY (id);


--
-- Name: tastypie_apiaccess_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apiaccess
    ADD CONSTRAINT tastypie_apiaccess_pkey PRIMARY KEY (id);


--
-- Name: tastypie_apikey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apikey
    ADD CONSTRAINT tastypie_apikey_pkey PRIMARY KEY (id);


--
-- Name: tastypie_apikey_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apikey
    ADD CONSTRAINT tastypie_apikey_user_id_key UNIQUE (user_id);


--
-- Name: auth_group_name_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_like ON auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id ON auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id ON auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id ON auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_group_id ON auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_user_id ON auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_permission_id ON auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_user_id ON auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_like ON auth_user USING btree (username varchar_pattern_ops);


--
-- Name: authtoken_token_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX authtoken_token_key_like ON authtoken_token USING btree (key varchar_pattern_ops);


--
-- Name: celery_taskmeta_hidden; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX celery_taskmeta_hidden ON celery_taskmeta USING btree (hidden);


--
-- Name: celery_taskmeta_task_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX celery_taskmeta_task_id_like ON celery_taskmeta USING btree (task_id varchar_pattern_ops);


--
-- Name: celery_tasksetmeta_hidden; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX celery_tasksetmeta_hidden ON celery_tasksetmeta USING btree (hidden);


--
-- Name: celery_tasksetmeta_taskset_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX celery_tasksetmeta_taskset_id_like ON celery_tasksetmeta USING btree (taskset_id varchar_pattern_ops);


--
-- Name: controlinterface_dashboard_widgets_dashboard_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_dashboard_widgets_dashboard_id ON controlinterface_dashboard_widgets USING btree (dashboard_id);


--
-- Name: controlinterface_dashboard_widgets_widget_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_dashboard_widgets_widget_id ON controlinterface_dashboard_widgets USING btree (widget_id);


--
-- Name: controlinterface_userdashboard_dashboards_dashboard_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_userdashboard_dashboards_dashboard_id ON controlinterface_userdashboard_dashboards USING btree (dashboard_id);


--
-- Name: controlinterface_userdashboard_dashboards_userdashboard_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_userdashboard_dashboards_userdashboard_id ON controlinterface_userdashboard_dashboards USING btree (userdashboard_id);


--
-- Name: controlinterface_userdashboard_default_dashboard_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_userdashboard_default_dashboard_id ON controlinterface_userdashboard USING btree (default_dashboard_id);


--
-- Name: controlinterface_widget_data_widget_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_widget_data_widget_id ON controlinterface_widget_data USING btree (widget_id);


--
-- Name: controlinterface_widget_data_widgetdata_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX controlinterface_widget_data_widgetdata_id ON controlinterface_widget_data USING btree (widgetdata_id);


--
-- Name: django_admin_log_content_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id ON django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id ON django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date ON django_session USING btree (expire_date);


--
-- Name: django_session_session_key_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_like ON django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: djcelery_periodictask_crontab_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_periodictask_crontab_id ON djcelery_periodictask USING btree (crontab_id);


--
-- Name: djcelery_periodictask_interval_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_periodictask_interval_id ON djcelery_periodictask USING btree (interval_id);


--
-- Name: djcelery_periodictask_name_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_periodictask_name_like ON djcelery_periodictask USING btree (name varchar_pattern_ops);


--
-- Name: djcelery_taskstate_hidden; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_hidden ON djcelery_taskstate USING btree (hidden);


--
-- Name: djcelery_taskstate_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_name ON djcelery_taskstate USING btree (name);


--
-- Name: djcelery_taskstate_name_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_name_like ON djcelery_taskstate USING btree (name varchar_pattern_ops);


--
-- Name: djcelery_taskstate_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_state ON djcelery_taskstate USING btree (state);


--
-- Name: djcelery_taskstate_state_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_state_like ON djcelery_taskstate USING btree (state varchar_pattern_ops);


--
-- Name: djcelery_taskstate_task_id_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_task_id_like ON djcelery_taskstate USING btree (task_id varchar_pattern_ops);


--
-- Name: djcelery_taskstate_tstamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_tstamp ON djcelery_taskstate USING btree (tstamp);


--
-- Name: djcelery_taskstate_worker_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_taskstate_worker_id ON djcelery_taskstate USING btree (worker_id);


--
-- Name: djcelery_workerstate_hostname_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_workerstate_hostname_like ON djcelery_workerstate USING btree (hostname varchar_pattern_ops);


--
-- Name: djcelery_workerstate_last_heartbeat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX djcelery_workerstate_last_heartbeat ON djcelery_workerstate USING btree (last_heartbeat);


--
-- Name: nursereg_nursereg_nurse_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nursereg_nursereg_nurse_source_id ON nursereg_nursereg USING btree (nurse_source_id);


--
-- Name: nursereg_nursesource_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nursereg_nursesource_user_id ON nursereg_nursesource USING btree (user_id);


--
-- Name: registration_registration_mom_msisdn; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX registration_registration_mom_msisdn ON registration_registration USING btree (mom_msisdn);


--
-- Name: registration_registration_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX registration_registration_source_id ON registration_registration USING btree (source_id);


--
-- Name: registration_source_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX registration_source_user_id ON registration_source USING btree (user_id);


--
-- Name: servicerating_contact_conversation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX servicerating_contact_conversation_id ON servicerating_contact USING btree (conversation_id);


--
-- Name: servicerating_conversation_user_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX servicerating_conversation_user_account_id ON servicerating_conversation USING btree (user_account_id);


--
-- Name: servicerating_extra_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX servicerating_extra_contact_id ON servicerating_extra USING btree (contact_id);


--
-- Name: servicerating_response_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX servicerating_response_contact_id ON servicerating_response USING btree (contact_id);


--
-- Name: snappybouncer_conversation_user_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX snappybouncer_conversation_user_account_id ON snappybouncer_conversation USING btree (user_account_id);


--
-- Name: snappybouncer_ticket_conversation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX snappybouncer_ticket_conversation_id ON snappybouncer_ticket USING btree (conversation_id);


--
-- Name: subscription_message_message_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_message_message_set_id ON subscription_message USING btree (message_set_id);


--
-- Name: subscription_messageset_default_schedule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_messageset_default_schedule_id ON subscription_messageset USING btree (default_schedule_id);


--
-- Name: subscription_messageset_next_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_messageset_next_set_id ON subscription_messageset USING btree (next_set_id);


--
-- Name: subscription_subscription_message_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_subscription_message_set_id ON subscription_subscription USING btree (message_set_id);


--
-- Name: subscription_subscription_schedule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_subscription_schedule_id ON subscription_subscription USING btree (schedule_id);


--
-- Name: subscription_subscription_to_addr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subscription_subscription_to_addr ON subscription_subscription USING btree (to_addr);


--
-- Name: tastypie_apikey_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tastypie_apikey_key ON tastypie_apikey USING btree (key);


--
-- Name: auth_group_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: contact_id_refs_id_2872152c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_extra
    ADD CONSTRAINT contact_id_refs_id_2872152c FOREIGN KEY (contact_id) REFERENCES servicerating_contact(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: contact_id_refs_id_80fb7b47; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_response
    ADD CONSTRAINT contact_id_refs_id_80fb7b47 FOREIGN KEY (contact_id) REFERENCES servicerating_contact(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: content_type_id_refs_id_d043b34a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT content_type_id_refs_id_d043b34a FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: conversation_id_refs_id_36c9d700; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_ticket
    ADD CONSTRAINT conversation_id_refs_id_36c9d700 FOREIGN KEY (conversation_id) REFERENCES snappybouncer_conversation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: conversation_id_refs_id_3af163c3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_contact
    ADD CONSTRAINT conversation_id_refs_id_3af163c3 FOREIGN KEY (conversation_id) REFERENCES servicerating_conversation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: crontab_id_refs_id_286da0d1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictask
    ADD CONSTRAINT crontab_id_refs_id_286da0d1 FOREIGN KEY (crontab_id) REFERENCES djcelery_crontabschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_id_refs_id_4c95605a; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard_widgets
    ADD CONSTRAINT dashboard_id_refs_id_4c95605a FOREIGN KEY (dashboard_id) REFERENCES controlinterface_dashboard(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dashboard_id_refs_id_fd5f9f10; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard_dashboards
    ADD CONSTRAINT dashboard_id_refs_id_fd5f9f10 FOREIGN KEY (dashboard_id) REFERENCES controlinterface_dashboard(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: default_dashboard_id_refs_id_5424e490; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard
    ADD CONSTRAINT default_dashboard_id_refs_id_5424e490 FOREIGN KEY (default_dashboard_id) REFERENCES controlinterface_dashboard(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: default_schedule_id_refs_id_286d8f16; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_messageset
    ADD CONSTRAINT default_schedule_id_refs_id_286d8f16 FOREIGN KEY (default_schedule_id) REFERENCES djcelery_periodictask(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log_content_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_fkey FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: group_id_refs_id_f4b32aac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_group_permissions
    ADD CONSTRAINT group_id_refs_id_f4b32aac FOREIGN KEY (group_id) REFERENCES auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: interval_id_refs_id_1829f358; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_periodictask
    ADD CONSTRAINT interval_id_refs_id_1829f358 FOREIGN KEY (interval_id) REFERENCES djcelery_intervalschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: message_set_id_refs_id_2a22aa85; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_subscription
    ADD CONSTRAINT message_set_id_refs_id_2a22aa85 FOREIGN KEY (message_set_id) REFERENCES subscription_messageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: message_set_id_refs_id_7fd3a880; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_message
    ADD CONSTRAINT message_set_id_refs_id_7fd3a880 FOREIGN KEY (message_set_id) REFERENCES subscription_messageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: next_set_id_refs_id_e3a1d20d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_messageset
    ADD CONSTRAINT next_set_id_refs_id_e3a1d20d FOREIGN KEY (next_set_id) REFERENCES subscription_messageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: nurse_source_id_refs_id_44aa787d; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursereg
    ADD CONSTRAINT nurse_source_id_refs_id_44aa787d FOREIGN KEY (nurse_source_id) REFERENCES nursereg_nursesource(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: schedule_id_refs_id_616c7a3b; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subscription_subscription
    ADD CONSTRAINT schedule_id_refs_id_616c7a3b FOREIGN KEY (schedule_id) REFERENCES djcelery_periodictask(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: source_id_refs_id_5f60989c; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_registration
    ADD CONSTRAINT source_id_refs_id_5f60989c FOREIGN KEY (source_id) REFERENCES registration_source(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_account_id_refs_id_41d31760; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY servicerating_conversation
    ADD CONSTRAINT user_account_id_refs_id_41d31760 FOREIGN KEY (user_account_id) REFERENCES servicerating_useraccount(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_account_id_refs_id_c902ef67; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY snappybouncer_conversation
    ADD CONSTRAINT user_account_id_refs_id_c902ef67 FOREIGN KEY (user_account_id) REFERENCES snappybouncer_useraccount(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_40c41112; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_groups
    ADD CONSTRAINT user_id_refs_id_40c41112 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_4dc23c39; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY auth_user_user_permissions
    ADD CONSTRAINT user_id_refs_id_4dc23c39 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_8dc183ba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY registration_source
    ADD CONSTRAINT user_id_refs_id_8dc183ba FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_990aee10; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tastypie_apikey
    ADD CONSTRAINT user_id_refs_id_990aee10 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_e0dac340; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nursereg_nursesource
    ADD CONSTRAINT user_id_refs_id_e0dac340 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_eade4620; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY authtoken_token
    ADD CONSTRAINT user_id_refs_id_eade4620 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_id_refs_id_ef619fc9; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard
    ADD CONSTRAINT user_id_refs_id_ef619fc9 FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: userdashboard_id_refs_id_025cd3dc; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_userdashboard_dashboards
    ADD CONSTRAINT userdashboard_id_refs_id_025cd3dc FOREIGN KEY (userdashboard_id) REFERENCES controlinterface_userdashboard(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: widget_id_refs_id_35994d88; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_dashboard_widgets
    ADD CONSTRAINT widget_id_refs_id_35994d88 FOREIGN KEY (widget_id) REFERENCES controlinterface_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: widget_id_refs_id_999f9bb4; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget_data
    ADD CONSTRAINT widget_id_refs_id_999f9bb4 FOREIGN KEY (widget_id) REFERENCES controlinterface_widget(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: widgetdata_id_refs_id_4647dbba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controlinterface_widget_data
    ADD CONSTRAINT widgetdata_id_refs_id_4647dbba FOREIGN KEY (widgetdata_id) REFERENCES controlinterface_widgetdata(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: worker_id_refs_id_6fd8ce95; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY djcelery_taskstate
    ADD CONSTRAINT worker_id_refs_id_6fd8ce95 FOREIGN KEY (worker_id) REFERENCES djcelery_workerstate(id) DEFERRABLE INITIALLY DEFERRED;


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

