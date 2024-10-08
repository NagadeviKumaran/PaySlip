PGDMP  $    
                |            PaySlip    16.3    16.3     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16577    PaySlip    DATABASE     |   CREATE DATABASE "PaySlip" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_India.1252';
    DROP DATABASE "PaySlip";
                postgres    false            �            1255    16822    get_payslip_json(integer)    FUNCTION     �  CREATE FUNCTION public.get_payslip_json(emp_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE 
    result JSON;
BEGIN
    SELECT json_build_object(
        'public_employee', 
        json_build_array(json_build_object(
            'Name', e.Name,
            'EmpID', e.EmpID,
            'UAN', e.UAN,
            'Designation', e.Designation,
            'DateOfJoining', to_char(e.DateOfJoining, 'YYYY-MM-DD HH24:MI:SS'),
            'Bank', e.Bank,
            'BankAcNo', e.BankAcNo,
            'SalaryCreditMode', e.SalaryCreditMode,
            'TotalCalendarDays', e.TotalCalendarDays,
            'LOPDays', e.LOPDays,
            'PaidDays', e.PaidDays,
            'GrossPay', e.GrossPay
        )),
        'public_earnings', 
        (SELECT json_agg(json_build_object('Description', Description, 'Amount', Amount)) 
         FROM Earnings WHERE EmpID = emp_id),
        'public_deductions', 
        (SELECT json_agg(json_build_object('Description', Description, 'Amount', Amount)) 
         FROM Deductions WHERE EmpID = emp_id)
    ) INTO result
    FROM Employee e 
    WHERE e.EmpID = emp_id;
    
    RETURN result;
END;
$$;
 7   DROP FUNCTION public.get_payslip_json(emp_id integer);
       public          postgres    false            �            1259    16814 
   deductions    TABLE     x   CREATE TABLE public.deductions (
    empid integer,
    description character varying(100),
    amount numeric(10,2)
);
    DROP TABLE public.deductions;
       public         heap    postgres    false            �            1259    16806    earnings    TABLE     v   CREATE TABLE public.earnings (
    empid integer,
    description character varying(100),
    amount numeric(10,2)
);
    DROP TABLE public.earnings;
       public         heap    postgres    false            �            1259    16800    employee    TABLE     �  CREATE TABLE public.employee (
    empid integer NOT NULL,
    name character varying(100),
    uan character varying(20),
    designation character varying(100),
    dateofjoining timestamp without time zone,
    bank character varying(100),
    bankacno character varying(50),
    salarycreditmode character varying(50),
    totalcalendardays integer,
    lopdays integer,
    paiddays integer,
    grosspay numeric(10,2)
);
    DROP TABLE public.employee;
       public         heap    postgres    false            �            1259    16799    employee_empid_seq    SEQUENCE     �   CREATE SEQUENCE public.employee_empid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.employee_empid_seq;
       public          postgres    false    216            �           0    0    employee_empid_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.employee_empid_seq OWNED BY public.employee.empid;
          public          postgres    false    215            Y           2604    16803    employee empid    DEFAULT     p   ALTER TABLE ONLY public.employee ALTER COLUMN empid SET DEFAULT nextval('public.employee_empid_seq'::regclass);
 =   ALTER TABLE public.employee ALTER COLUMN empid DROP DEFAULT;
       public          postgres    false    216    215    216            �          0    16814 
   deductions 
   TABLE DATA           @   COPY public.deductions (empid, description, amount) FROM stdin;
    public          postgres    false    218   `       �          0    16806    earnings 
   TABLE DATA           >   COPY public.earnings (empid, description, amount) FROM stdin;
    public          postgres    false    217   �       �          0    16800    employee 
   TABLE DATA           �   COPY public.employee (empid, name, uan, designation, dateofjoining, bank, bankacno, salarycreditmode, totalcalendardays, lopdays, paiddays, grosspay) FROM stdin;
    public          postgres    false    216   V       �           0    0    employee_empid_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.employee_empid_seq', 1, true);
          public          postgres    false    215            [           2606    16805    employee employee_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (empid);
 @   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_pkey;
       public            postgres    false    216            ]           2606    16817     deductions deductions_empid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_empid_fkey FOREIGN KEY (empid) REFERENCES public.employee(empid);
 J   ALTER TABLE ONLY public.deductions DROP CONSTRAINT deductions_empid_fkey;
       public          postgres    false    4699    218    216            \           2606    16809    earnings earnings_empid_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.earnings
    ADD CONSTRAINT earnings_empid_fkey FOREIGN KEY (empid) REFERENCES public.employee(empid);
 F   ALTER TABLE ONLY public.earnings DROP CONSTRAINT earnings_empid_fkey;
       public          postgres    false    216    217    4699            �   k   x�3�pSp�-�ɯLMUp��+)�L*-����415�30�2�t�TpIM)M	sYB�}���р�����b��BHb��1D8�%�¿$#��@�x� ��'�      �   k   x�3�tr�tV�Vpq�4�00�30�2��r�2����R+�Ssr��A,��Yj�BHfn��kbQ^f^z1�׊��Ғ�2,�}SS2�s��[�4M8F��� �+1\      �   o   x��A
�0F������Lc��7n��T��J�������tק�N�8���1��M�7[�=l��O8bϗ6�V"uu�����eN���@�&��4�����NJ     