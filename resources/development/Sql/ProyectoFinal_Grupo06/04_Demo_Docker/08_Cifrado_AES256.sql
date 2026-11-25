/* =============================================================================
   FASE 8 · CIFRADO AES_256 DE DATOS PERSONALES (Ley 29733)
   Ejecutar como: sa                      ./demo.sh 08
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 8.1 Jerarquía: Service Master Key -> DMK -> Certificado -> Llave AES_256 ===';
SELECT N'Llave' AS tipo, name AS nombre, algorithm_desc AS algoritmo, key_length AS bits,
       CAST(create_date AS DATE) AS creada
FROM sys.symmetric_keys
UNION ALL
SELECT N'Certificado', name, pvt_key_encryption_type_desc, NULL, CAST(expiry_date AS DATE)
FROM sys.certificates WHERE name = N'Cert_AkilFlow_Operaciones';
SELECT name AS base, is_master_key_encrypted_by_server AS dmk_protegida_por_smk
FROM sys.databases WHERE name = DB_NAME();
GO
PRINT N'=== 8.2 Ya no existe ninguna columna en texto plano con datos personales ===';
SELECT c.name AS columna, t.name AS tipo, c.max_length AS bytes
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.encomiendas') AND c.name LIKE N'%cif';
GO
PRINT N'=== 8.3 SIN la llave: lo que vería alguien que roba la base ===';
SELECT TOP (3) codigo_rastreo, remitente_cif, telefono_destinatario_cif
FROM dbo.encomiendas ORDER BY encomienda_id;
GO
PRINT N'=== 8.4 CON la llave abierta: texto descifrado ===';
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT TOP (3) codigo_rastreo,
       CAST(DecryptByKey(remitente_cif)             AS NVARCHAR(120)) AS remitente,
       CAST(DecryptByKey(documento_remitente_cif)   AS VARCHAR(11))   AS documento,
       CAST(DecryptByKey(destinatario_cif)          AS NVARCHAR(120)) AS destinatario,
       CAST(DecryptByKey(telefono_destinatario_cif) AS VARCHAR(12))   AS telefono
FROM dbo.encomiendas ORDER BY encomienda_id;
GO
PRINT N'=== 8.5 Cifrado no determinista: el mismo texto produce binarios distintos ===';
SELECT EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), N'Juan Pérez') AS cifrado_1,
       EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), N'Juan Pérez') AS cifrado_2;
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
PRINT N'=== 8.6 Llave cerrada: DecryptByKey devuelve NULL ===';
SELECT TOP (2) codigo_rastreo, CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS remitente
FROM dbo.encomiendas ORDER BY encomienda_id;
GO
PRINT N'>>> FASE 8 OK: datos personales protegidos con AES_256; solo los SP autorizados los descifran.';
GO
