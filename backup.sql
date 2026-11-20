--
-- PostgreSQL database dump
--

\restrict X6ojvtepqy7uFm9C3om4KnJRdPFiQFjWaBSuUnAoWuFwGBt6DaaxgNKbr5TGKMY

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: movement; Type: TABLE; Schema: public; Owner: bar
--

CREATE TABLE public.movement (
    id integer NOT NULL,
    product_id integer NOT NULL,
    kind character varying(20) NOT NULL,
    quantity numeric(12,3) NOT NULL,
    balance numeric(12,3) NOT NULL,
    note character varying(250) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.movement OWNER TO bar;

--
-- Name: movement_id_seq; Type: SEQUENCE; Schema: public; Owner: bar
--

CREATE SEQUENCE public.movement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movement_id_seq OWNER TO bar;

--
-- Name: movement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bar
--

ALTER SEQUENCE public.movement_id_seq OWNED BY public.movement.id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: bar
--

CREATE TABLE public.product (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    sku character varying(60) NOT NULL,
    category character varying(60) NOT NULL,
    unit character varying(20) NOT NULL,
    stock numeric(12,3) NOT NULL,
    minimum numeric(12,3) NOT NULL,
    cost numeric(12,2) NOT NULL,
    active boolean NOT NULL,
    brand character varying(60) DEFAULT ''::character varying NOT NULL,
    CONSTRAINT product_check CHECK (((stock >= (0)::numeric) AND (minimum >= (0)::numeric) AND (cost >= (0)::numeric)))
);


ALTER TABLE public.product OWNER TO bar;

--
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: bar
--

CREATE SEQUENCE public.product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_id_seq OWNER TO bar;

--
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bar
--

ALTER SEQUENCE public.product_id_seq OWNED BY public.product.id;


--
-- Name: movement id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.movement ALTER COLUMN id SET DEFAULT nextval('public.movement_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Data for Name: movement; Type: TABLE DATA; Schema: public; Owner: bar
--

COPY public.movement (id, product_id, kind, quantity, balance, note, created_at) FROM stdin;
1	1	Entrada	1.000	1.000	inventario	2026-10-31 02:00:07.056252
2	2	Inventario	1.000	1.000	Inventario	2026-10-31 02:02:07.988471
3	3	Inventario	1.000	1.000	Inventario	2026-10-31 02:12:42.40987
4	4	Inventario	2.000	2.000	inventario	2026-10-31 02:14:34.630984
5	5	Inventario	1.000	1.000	inventario	2026-10-31 02:17:08.065867
6	6	Inventario	1.000	1.000	INVENTARIO	2026-10-31 02:20:56.754325
7	7	Inventario	1.000	1.000	inventario	2026-10-31 02:23:07.773185
8	8	Inventario	1.000	1.000	inventario	2026-10-31 02:31:18.813252
9	11	Inventario	1.000	1.000	inventario	2026-10-31 02:31:27.385093
10	13	Entrada	1.000	1.000	inventario	2026-10-31 02:31:36.557099
11	12	Entrada	1.000	1.000	inventario	2026-10-31 02:31:45.911237
12	9	Inventario	1.000	1.000	inventario	2026-10-31 02:31:53.045449
13	15	Inventario	1.000	1.000	inventario	2026-10-31 02:35:28.476253
14	14	Entrada	1.000	1.000	inventario	2026-10-31 02:35:48.458271
15	16	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:37:54.440416
16	17	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:40:01.622885
17	18	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:44:27.932407
18	19	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:46:26.803024
19	20	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:48:29.673975
20	21	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:50:39.238837
21	22	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:54:41.590115
22	23	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:56:21.168307
23	24	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:57:05.827237
24	25	Inventario	1.000	1.000	Stock inicial	2026-10-31 02:58:48.475076
25	26	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:00:32.393626
26	27	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:04:10.585301
27	28	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:05:46.104216
28	30	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:07:24.768329
29	31	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:08:44.700125
30	32	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:14:06.400762
31	33	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:16:03.771951
32	34	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:18:13.67872
33	35	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:19:24.608952
34	36	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:20:17.941523
35	38	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:21:16.568089
36	39	Inventario	2.000	2.000	Stock inicial	2026-10-31 03:21:49.298216
37	40	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:24:36.61304
38	41	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:25:47.247992
39	42	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:26:27.476362
40	43	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:30:29.820284
41	44	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:31:01.569273
42	46	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:31:56.842078
43	47	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:32:28.474924
44	48	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:32:54.130705
45	49	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:33:26.857127
46	50	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:36:22.878237
47	51	Inventario	1.000	1.000	Stock inicial	2026-10-31 03:36:53.677699
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: bar
--

COPY public.product (id, name, sku, category, unit, stock, minimum, cost, active, brand) FROM stdin;
1	Gienbra	GIN01	Destilado	botella	1.000	0.000	15000.00	t	Bols
2	Gin Floral	GIN02	Destilado	unidad	1.000	0.000	30000.00	t	Salamanca de las Brujas
3	Gin Londom Dry	GIN03	Destilados	botella	1.000	0.000	35000.00	t	Tanqueray
4	Vodka	VODKA01	Destilados	botella	2.000	0.000	12000.00	t	smirnoff
5	Abesenta	ABS01	Destilados	botella	1.000	0.000	35000.00	t	Vert
6	Sake	SAKE01	Destilados	botella	1.000	0.000	10000.00	t	chum churum
7	Tequila	TEQ01	Destilados	botella	1.000	0.000	50000.00	t	Jose Cuervo Reposado
8	Ron Anejo	RON01	Destilados	botella	1.000	0.000	25000.00	t	centenario
11	Ron Añejo	RON03	Destilados	botella	1.000	0.000	150000.00	t	Diplomatico
13	Ron Blanco	RON05	Destilados	botella	1.000	0.000	25000.00	t	Havana Club
12	Ron Especiado	RON04	Destilados	botella	1.000	0.000	20000.00	t	Havana Club Especiado
9	Ron añejo	RON02	Destilados	botella	1.000	0.000	35000.00	t	Havana Club 7 años
15	Pisco	PISCO02	Destilados	botella	1.000	0.000	25000.00	t	Calavera
14	Pisco	PISCO01	Destilados	botella	1.000	0.000	25000.00	t	Mistral añejo
16	Cognag	COGNAG01	Destilados	botella	1.000	0.000	80000.00	t	Hennessy
17	Whisky Escoses Blend	WKY03	Destilados	botella	1.000	0.000	70000.00	t	Monkey Shoulder
18	Whisky Bourbon	WKY01	Destilados	botella	1.000	0.000	50000.00	t	Jim Beam
19	Wkisky Escoces Blend	WKY02	Destilados	botella	1.000	0.000	50000.00	t	Johnnie Walker  Red Label
20	Whysky Escoces Blend	WKY04	Destilados	botella	1.000	0.000	375000.00	t	Chivas Royal Salute 21 años
21	Wkisky Escoces Single Malt	WKY05	Destilados	botella	1.000	0.000	130000.00	t	Glenmorangie
22	Amaretto	LICOR01	Licor	botella	1.000	0.000	55000.00	t	Disaronno
23	Cherry Brandy	LICOR02	Licor	botella	1.000	0.000	35000.00	t	Golden Age
24	Apricot	LICOR03	Licor	botella	1.000	0.000	35000.00	t	Golden Age
25	Elderflower	LICOR04	Licor	botella	1.000	0.000	35000.00	t	Bols Amsterdam
26	Calafate	LICOR05	Licor	botella	1.000	0.000	20000.00	t	Danis PAtagonia
27	Cafe	LICOR06	Licor	botella	1.000	0.000	22000.00	t	Borghetti
28	Blue Curacao	LICOR07	Licor	botella	1.000	0.000	10000.00	t	Tres Plumas
30	Triple Sec	LICOR08	Licor	botella	1.000	0.000	12000.00	t	Tres Plumas
31	Fernet	FERNET01	Aperitivo	botella	1.000	0.000	10000.00	t	Buhero Negro
32	Campari	CAMPARI	Aperitivo	botella	1.000	0.000	12000.00	t	Campari
33	Aperol	APEROL	Aperitivo	botella	1.000	0.000	12000.00	t	APEROL
34	Vermut Rosso	VERMUT01	Vinos	botella	1.000	0.000	13000.00	t	MARTINI
35	Jerez	JEREZ01	Vinos	botella	1.000	0.000	12000.00	t	Federico Lopez
36	Tinto	TINTO	Vinos	botella	1.000	0.000	0.00	t	Varios
37	Blanco	BLANCO	Vinos	botella	0.000	0.000	0.00	t	VARIOS
38	Vermut Blanco	VERMUT02	Aperitivo	botella	1.000	0.000	15000.00	t	VARIOS
39	Espumante	CHAMP01	Vinos	botella	2.000	0.000	20000.00	t	VARIOS
40	Espumante	HALO01	Bitter	botella	1.000	0.000	50000.00	t	Halo
41	Angostura	BITTER01	Bitter	botella	1.000	0.000	60000.00	t	Angostura
42	Bitter Cacao	ANGOSTURA	Biter	botella	1.000	0.000	30000.00	t	Angostura
43	Bitter Floral	BITTER03	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
44	Bitter TIKI	BITTER04	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
46	Bitter Coco	BITTER05	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
47	Bitter Vintage	BITTER06	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
48	Bitter Menta	BITTER07	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
49	Bitter Barrica	BITTER08	Bitter	botella	1.000	0.000	15000.00	t	Gibsons
50	Falernum TIKI	BITTER09	Bitter	botella	1.000	0.000	5000.00	t	artedelbar
51	Pimiento Dram TIKI	BITTER10	Bitter	botella	1.000	0.000	5000.00	t	artedelbar
\.


--
-- Name: movement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.movement_id_seq', 47, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.product_id_seq', 51, true);


--
-- Name: movement movement_pkey; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.movement
    ADD CONSTRAINT movement_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product product_sku_key; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_sku_key UNIQUE (sku);


--
-- Name: movement movement_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.movement
    ADD CONSTRAINT movement_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- PostgreSQL database dump complete
--

\unrestrict X6ojvtepqy7uFm9C3om4KnJRdPFiQFjWaBSuUnAoWuFwGBt6DaaxgNKbr5TGKMY

