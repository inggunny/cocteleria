--
-- PostgreSQL database dump
--

\restrict FImGcVNJN7A5yHKd9K91sIxXadGbfvcfAalqH4NHBxwxWJ3RIvLf79mymJLpZUL

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
-- Name: cocktail; Type: TABLE; Schema: public; Owner: bar
--

CREATE TABLE public.cocktail (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    description character varying(500) NOT NULL,
    price numeric(12,2) NOT NULL,
    published boolean NOT NULL,
    CONSTRAINT cocktail_price_check CHECK ((price >= (0)::numeric))
);


ALTER TABLE public.cocktail OWNER TO bar;

--
-- Name: cocktail_id_seq; Type: SEQUENCE; Schema: public; Owner: bar
--

CREATE SEQUENCE public.cocktail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cocktail_id_seq OWNER TO bar;

--
-- Name: cocktail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bar
--

ALTER SEQUENCE public.cocktail_id_seq OWNED BY public.cocktail.id;


--
-- Name: ingredient; Type: TABLE; Schema: public; Owner: bar
--

CREATE TABLE public.ingredient (
    id integer NOT NULL,
    cocktail_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric(12,3) NOT NULL,
    CONSTRAINT ingredient_quantity_check CHECK ((quantity > (0)::numeric))
);


ALTER TABLE public.ingredient OWNER TO bar;

--
-- Name: ingredient_id_seq; Type: SEQUENCE; Schema: public; Owner: bar
--

CREATE SEQUENCE public.ingredient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredient_id_seq OWNER TO bar;

--
-- Name: ingredient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bar
--

ALTER SEQUENCE public.ingredient_id_seq OWNED BY public.ingredient.id;


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
-- Name: cocktail id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.cocktail ALTER COLUMN id SET DEFAULT nextval('public.cocktail_id_seq'::regclass);


--
-- Name: ingredient id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.ingredient ALTER COLUMN id SET DEFAULT nextval('public.ingredient_id_seq'::regclass);


--
-- Name: movement id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.movement ALTER COLUMN id SET DEFAULT nextval('public.movement_id_seq'::regclass);


--
-- Name: product id; Type: DEFAULT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT nextval('public.product_id_seq'::regclass);


--
-- Data for Name: cocktail; Type: TABLE DATA; Schema: public; Owner: bar
--

COPY public.cocktail (id, name, description, price, published) FROM stdin;
3	Americano	Vermut Rosso estilo torino + Campari + Soda	1.00	t
2	Mito	Vermut Rosso estilo torino + Campari	1.00	t
5	Dry Martini ( de la casa)	Jerez y gin londron dry + aceituna	1.00	t
1	Negroni	Vermut Rosso estilo torino + Campari + Gin london dry	1.00	t
4	Daiquiri	el original: ron blanco + limon + almibar simple	1.00	t
6	Tom Collins	Gin +Limon +Almibar simple + Soda	1.00	t
7	Manhattan	Whisky Bourbone + Vermut Rosso + bitter Angostura + cereza	1.00	t
8	Old Fashion	Whisky Bourbone + Bitter Angostura + azucar/almibar	1.00	t
9	Sidecar	Cognac + Triple Sec + Jugo de Limon	1.00	t
10	Sazerac	Cognac + Absenta + Azucar/Almibar + Bitter Angostura	1.00	t
11	Whisky Sour	Whisky o cualquier otra version Sour, Apto vegano\r\n Whisky (o Bebida alcoholica base) + Limon + Almibar + Halo + bitter angostura	1.00	t
12	White lady	Tambien disponible version Blue Lady\r\nGin + Triple Sec/ Blue Curacao + Jugo de limon + Halo	1.00	t
13	Black Russian	Vodka + Licor de Cafe	1.00	t
14	French Connection	Cognac + Amaretto	1.00	t
15	God Father	Whisky Escoces Blend + Amaretto	1.00	t
16	Margarita	Tequila + Triple Sec + Limon	1.00	t
17	Mimosa	Espumante + Jugo de Naranja	1.00	t
18	Mint Julep	Whisky Bourbone + Menta + Almibar	1.00	t
19	Mojito	(Disponible version malibu)\r\nRon Blanco + Jugo de Limon + Almibar + Menta + Soda ( + bitter de coco para malibu)	1.00	t
20	New York Sour	Whisky Bourbone + Almibar + Limon + Vino tinto + Halo + bitter angostura	1.00	t
21	Golden Rush	Whisky Bourbone + Jugo de Limon+ Almibar de Miel	1.00	t
22	Rob Roy	Whisky Escoces + Vermut Rosso + Bitter Angostura + Cereza	1.00	t
23	Hanky Panky	Ginebra + Vermut Rosso + Fernet	1.00	t
24	Ferroviario	Fernet + Vermut Rosso + Soda	1.00	t
25	RUTA 40 - Acto 1	Gienbra + Jugo de Limon + Almibar Simple + Solusion Salina + Infusion Gasificada de Hojas de Coca	1.00	t
26	RUTA 40 - Acto 2	Blend de rones + Falernum + Pimiento Dram + Jugo de Limon + Jugo de Naranja + Almibar de Miel + Bitter TIKI	1.00	t
27	RUTA 40 - Acto 3	Pisco Estilo Peruano + Almibar + Limon + Infusion en Frio de Jarilla + Aceite de Oliva	1.00	t
28	RUTA 40 - Acto 4	Whisky Escoces Blend + Licor de Calafate + Infusion Austral + Bitter Angostura	1.00	t
30	GOTH - Acto 2	Ginebra + Vermu Rosso +  Bitter Angostura  + Licor de Cerry Brandy + Cereza	1.00	t
31	GOTH - Acto 3	Pisco Estilo Chileno + Jugo de limon + Almíbar Simple + Vino Tinto + Halo + Bitter Barrica	1.00	t
29	GOTH - Acto 1	Gin floral  + Licor Elderflowers  + Jugo de Limon  + Infusión de jazmín carbonatada + Bitter Floral	1.00	t
32	GOTH - Acto 4	Blend de rones ahumados + Jugo de limon + Falernum + Almíbar de miel + Licor de Apricot + Absenta + Bitter TIKI	1.00	t
33	GOTH - Acto 5	Absenta + Espumante	1.00	t
34	Bosque Alegre	(By Policastro)\r\nLicor de Cherry Brandy (20) + Licor de Apricot (10) + Jerez (20) + Cognac (30) + Espumante	1.00	t
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: public; Owner: bar
--

COPY public.ingredient (id, cocktail_id, product_id, quantity) FROM stdin;
24	3	32	1.000
25	3	66	1.000
26	3	34	1.000
27	2	32	1.000
28	2	34	1.000
29	5	3	1.000
30	5	35	1.000
31	5	67	1.000
32	1	3	1.000
33	1	32	1.000
34	1	34	1.000
35	4	13	1.000
36	4	59	1.000
37	4	57	1.000
45	7	18	1.000
46	7	41	1.000
47	7	34	1.000
48	7	68	1.000
52	9	16	1.000
53	9	30	1.000
54	9	57	1.000
55	10	5	1.000
56	10	59	1.000
57	10	16	1.000
58	10	41	1.000
59	11	18	1.000
60	11	59	1.000
61	11	57	1.000
62	11	40	1.000
63	11	41	1.000
64	12	3	1.000
65	12	30	1.000
66	12	57	1.000
67	12	40	1.000
68	13	4	1.000
69	13	27	1.000
70	14	22	1.000
71	14	16	1.000
72	15	22	1.000
73	15	17	1.000
74	16	30	1.000
75	16	7	1.000
76	16	57	1.000
77	17	61	1.000
78	17	39	1.000
79	18	59	1.000
80	18	69	1.000
81	18	18	1.000
82	19	57	1.000
83	19	59	1.000
84	19	13	1.000
85	19	66	1.000
86	19	69	1.000
87	20	18	1.000
88	20	59	1.000
89	20	41	1.000
90	20	40	1.000
91	20	57	1.000
92	20	36	1.000
93	21	60	1.000
94	21	57	1.000
95	21	18	1.000
96	22	19	1.000
97	22	34	1.000
98	22	41	1.000
99	22	68	1.000
100	6	3	1.000
101	6	59	1.000
102	6	57	1.000
103	6	66	1.000
104	6	68	1.000
105	8	18	1.000
106	8	41	1.000
107	8	59	1.000
108	8	68	1.000
109	23	1	1.000
110	23	34	1.000
111	23	31	1.000
112	24	31	1.000
113	24	66	1.000
114	24	34	1.000
115	25	54	1.000
116	25	1	1.000
117	25	57	1.000
118	25	59	1.000
119	25	58	1.000
120	26	13	1.000
121	26	12	1.000
122	26	44	1.000
123	26	50	1.000
124	26	51	1.000
125	26	57	1.000
126	26	61	1.000
127	26	60	1.000
128	27	15	1.000
129	27	56	1.000
130	27	59	1.000
131	27	57	1.000
132	27	52	1.000
133	28	41	1.000
134	28	19	1.000
135	28	26	1.000
136	28	55	1.000
141	30	23	1.000
142	30	1	1.000
143	30	34	1.000
144	30	41	1.000
145	30	68	1.000
146	31	14	1.000
147	31	57	1.000
148	31	59	1.000
149	31	36	1.000
150	31	40	1.000
151	31	49	1.000
152	29	2	1.000
153	29	25	1.000
154	29	53	1.000
155	29	57	1.000
156	29	43	1.000
157	32	8	1.000
158	32	12	1.000
159	32	13	1.000
160	32	57	1.000
161	32	50	1.000
162	32	44	1.000
163	32	60	1.000
164	32	24	1.000
165	32	5	1.000
166	33	5	1.000
167	33	39	1.000
168	34	23	1.000
169	34	24	1.000
170	34	35	1.000
171	34	16	1.000
172	34	39	1.000
\.


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
48	52	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:36:44.510848
49	53	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:37:03.24577
50	56	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:38:29.706999
51	57	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:38:51.740732
52	59	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:40:32.560276
53	66	Inventario	2.000	2.000	Stock inicial	2026-10-31 04:50:20.019067
54	67	Inventario	1.000	1.000	Stock inicial	2026-10-31 04:57:04.533274
55	68	Inventario	1.000	1.000	Stock inicial	2026-10-31 05:03:50.403273
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: bar
--

COPY public.product (id, name, sku, category, unit, stock, minimum, cost, active, brand) FROM stdin;
56	Aceite de Oliva	OIL01	Insumos	botella	1.000	0.000	0.00	t	Laur
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
35	Jerez	JEREZ01	Vinos	botella	1.000	0.000	12000.00	t	Federico Lopez
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
63	Arandanos	ARANDANOS	Jugo	botella	0.000	0.000	0.00	t	
60	Almibar de Miel	ALMIBAR02	Almibar	botella	0.000	0.000	0.00	t	casero
59	Almibar Simple	ALMINAR01	Almibar	botella	1.000	0.000	0.00	t	casero
64	Anana	ANANA	Jugo	botella	0.000	0.000	0.00	t	casero
54	Coca	TECOCA	Infucion	botella	0.000	0.000	0.00	t	casero
65	Hidromiel	HIDROMIEL	Hidromiel	botella	0.000	0.000	0.00	t	casero
52	Jarilla	JARILLA	Infusion	botella	1.000	0.000	0.00	t	casero
53	Jazmin	JAZMIN	Infusion	botella	1.000	0.000	0.00	t	casero
57	Limon	LIMON	Jugo	botella	1.000	0.000	0.00	t	casero
61	Naranja	NARANJA	Jugo	botella	0.000	0.000	0.00	t	casero
55	Patagonico	TESUR	Infusion	botella	0.000	0.000	0.00	t	casero
58	Solucion Salina	SAL	Insumos	botella	0.000	0.000	0.00	t	casero
62	Pomelo	POMELO	Jugo	botella	0.000	0.000	0.00	t	casero
66	Soda	SODA	Insumos	botella	2.000	0.000	0.00	t	
34	Vermut Rosso	VERMUT01	Vinos	botella	1.000	0.000	13000.00	t	Torino
67	Aceituna	ACEITUNA	Insumos	botella	1.000	0.000	0.00	t	
68	Cerezas	CEREZA	Insumos	botella	1.000	0.000	0.00	t	
37	VIno Blanco	BLANCO	Vinos	botella	0.000	0.000	0.00	t	VARIOS
36	Vino Tinto	TINTO	Vinos	botella	1.000	0.000	0.00	t	Varios
69	Menta	MENTA	Insumos	botella	0.000	0.000	0.00	t	
\.


--
-- Name: cocktail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.cocktail_id_seq', 34, true);


--
-- Name: ingredient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.ingredient_id_seq', 172, true);


--
-- Name: movement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.movement_id_seq', 55, true);


--
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bar
--

SELECT pg_catalog.setval('public.product_id_seq', 69, true);


--
-- Name: cocktail cocktail_pkey; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.cocktail
    ADD CONSTRAINT cocktail_pkey PRIMARY KEY (id);


--
-- Name: ingredient ingredient_cocktail_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_cocktail_id_product_id_key UNIQUE (cocktail_id, product_id);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


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
-- Name: ingredient ingredient_cocktail_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_cocktail_id_fkey FOREIGN KEY (cocktail_id) REFERENCES public.cocktail(id);


--
-- Name: ingredient ingredient_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.ingredient
    ADD CONSTRAINT ingredient_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- Name: movement movement_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bar
--

ALTER TABLE ONLY public.movement
    ADD CONSTRAINT movement_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- PostgreSQL database dump complete
--

\unrestrict FImGcVNJN7A5yHKd9K91sIxXadGbfvcfAalqH4NHBxwxWJ3RIvLf79mymJLpZUL

