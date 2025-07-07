[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Lowercase accented characters
$lc_a_acute = [char]0x00E1    # á
$lc_e_acute = [char]0x00E9    # é
$lc_i_acute = [char]0x00ED    # í
$lc_o_acute = [char]0x00F3    # ó
$lc_u_acute = [char]0x00FA    # ú

$lc_a_grave = [char]0x00E0    # à
$lc_e_grave = [char]0x00E8    # è
$lc_i_grave = [char]0x00EC    # ì
$lc_o_grave = [char]0x00F2    # ò
$lc_u_grave = [char]0x00F9    # ù

$lc_a_circum = [char]0x00E2   # â
$lc_e_circum = [char]0x00EA   # ê
$lc_i_circum = [char]0x00EE   # î
$lc_o_circum = [char]0x00F4   # ô
$lc_u_circum = [char]0x00FB   # û

$lc_a_tilde = [char]0x00E3    # ã
$lc_o_tilde = [char]0x00F5    # õ

$lc_c_cedilla = [char]0x00E7  # ç

# Uppercase accented characters
$uc_a_acute = [char]0x00C1    # Á
$uc_e_acute = [char]0x00C9    # É
$uc_i_acute = [char]0x00CD    # Í
$uc_o_acute = [char]0x00D3    # Ó
$uc_u_acute = [char]0x00DA    # Ú

$uc_a_grave = [char]0x00C0    # À
$uc_e_grave = [char]0x00C8    # È
$uc_i_grave = [char]0x00CC    # Ì
$uc_o_grave = [char]0x00D2    # Ò
$uc_u_grave = [char]0x00D9    # Ù

$uc_a_circum = [char]0x00C2   # Â
$uc_e_circum = [char]0x00CA   # Ê
$uc_i_circum = [char]0x00CE   # Î
$uc_o_circum = [char]0x00D4   # Ô
$uc_u_circum = [char]0x00DB   # Û

$uc_a_tilde = [char]0x00C3    # Ã
$uc_o_tilde = [char]0x00D5    # Õ

$uc_c_cedilla = [char]0x00C7  # Ç
