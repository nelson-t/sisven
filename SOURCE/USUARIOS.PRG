* Programa para eliminar el '#0' en los nombres de usuarios
SET EXCLUSIVE OFF
USE v_rec_hd
* REPLACE ALL hr_usuario WITH LEFT(HR_USUARIO,AT('#',HR_USUARIO,1)-1)
