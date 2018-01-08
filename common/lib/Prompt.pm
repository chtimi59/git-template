#!/bin/perl
package Prompt;
use strict;
#use warnings;

my $fd = fileno(STDIN);

# http://manpagesfr.free.fr/man/man3/termios.3.html
# http://search.cpan.org/~markov/POSIX-1003-0.98/lib/POSIX/1003/Termios.pod
use POSIX qw(:termios_h);
my $term = POSIX::Termios->new($fd);

# = POSIX function tcgetattr
# récupère les paramètres associés à l'objet référencé par fd
# et les stocke dans la structure termios interne (accessible en perl via getxflag).
$term->getattr();
my $c_iflag = $term->getiflag();
my $c_oflag = $term->getoflag();
my $c_cflag = $term->getcflag();
my $c_lflag = $term->getlflag();
my %c_cc = (
    "VINTR" => [VINTR, $term->getcc(VINTR)],
    "VQUIT" => [VQUIT, $term->getcc(VQUIT)],
    "VERASE" => [VERASE, $term->getcc(VERASE)],
    "VKILL" => [VKILL, $term->getcc(VKILL)],
    "VEOF" => [VEOF, $term->getcc(VEOF)],
    "VMIN" => [VMIN, $term->getcc(VMIN)],
    "VEOL" => [VEOL, $term->getcc(VEOL)],
    "VTIME" => [VTIME, $term->getcc(VTIME)],
    "VSTART" => [VSTART, $term->getcc(VSTART)],
    "VSTOP" => [VSTOP, $term->getcc(VSTOP)],
    "VSUSP" => [VSUSP, $term->getcc(VSUSP)]
);

sub printStatus {
	print "----\n";
	print "POSIX Terminal\n";
	print "Expected Terminal Code: ECMA 048\n";
	print "OS: $^O\n";
	print "----\n";
	print "\n";
    # modes d'entrée
    # Constante pour l'attribut c_iflag :
    my $c_iflag = $term->getiflag();
    print ("c_iflag: $c_iflag\n");
    {
        # Ignorer les signaux BREAK en entrée.
        print ("  IGNBRK\n") if ($c_iflag & IGNBRK);
        # Si IGNBRK est indiqué, un caractère BREAK en entrée est ignoré.
        # S'il n'est pas indiqué, mais si BRKINT est présent, alors un BREAK videra les files d'attente en entrée et sortie,
        # et si le terminal contrôle un groupe de processus en avant-plan, un signal SIGINT sera envoyé à ce groupe.
        # Si ni IGNBRK ni BRKINT ne sont indiqués, un caractère BREAK sera lu comme un octet nul (« \0 »),
        # sauf si PARMRK est présent, auquel cas il sera lu comme une séquence \377 \0 \0.
        print ("  BRKINT\n") if ($c_iflag & BRKINT);
        # Ignorer les erreurs de format et de parité.
        print ("  IGNPAR\n") if ($c_iflag & IGNPAR);
        # Si IGNPAR n'est pas indiqué, un caractère ayant une erreur de parité ou de format est préfixé avec \377 \0.
        # Si ni IGNPAR ni PARMRK ne sont indiqués, un caractère contenant une erreur de parité ou de format est lu comme \0.
        print ("  PARMRK\n") if ($c_iflag & PARMRK);
        # Valider la vérification de parité en entrée.
        print ("  INPCK\n") if ($c_iflag & INPCK);
        # Éliminer le huitième bit.
        print ("  ISTRIP\n") if ($c_iflag & ISTRIP);
        # Convertir NL en CR en entrée.
        print ("  INLCR\n") if ($c_iflag & INLCR);
        # Ignorer CR en entrée.
        print ("  IGNCR\n") if ($c_iflag & IGNCR);
        # Convertir CR en NL en entrée, sauf si IGNCR est indiqué.
        print ("  ICRNL\n") if ($c_iflag & ICRNL);
        # Valider le contrôle de flux XON/XOFF en sortie.
        print ("  IXON\n") if ($c_iflag & IXON);
        # Valider le contrôle de flux XON/XOFF en entrée.
        print ("  IXOFF\n") if ($c_iflag & IXOFF);
    }
    # modes de sortie
    # Constantes pour l'attribut c_oflag :
    my $c_oflag = $term->getoflag();
    print ("c_oflag: $c_oflag\n");
    {
        # Traitement en sortie dépendant de l'implémentation
        print ("  OPOST\n") if ($c_oflag & OPOST);
    }
    # modes de contrôle
    # Constantes pour l'attribut c_cflag :
    my $c_cflag = $term->getcflag();
    print ("c_cflag: $c_cflag\n");
    {
        # Masque de longueur des caractères. Les valeurs sont CS5, CS6, CS7 ou CS8.
        print ("  CSIZE\n") if ($c_cflag & CSIZE);
        # Utiliser deux bits de stop plutôt qu'un.
        print ("  CSTOPB\n") if ($c_cflag & CSTOPB);
        # Valider la réception.
        print ("  CREAD\n") if ($c_cflag & CREAD);
        # Valider le codage de parité en sortie, et la vérification de parité en entrée.
        print ("  PARENB\n") if ($c_cflag & PARENB);
        # S'il est positionné, la parité en entrée et en sortie sera impaire ; sinon, une parité paire sera utilisée.
        print ("  PARODD\n") if ($c_cflag & PARODD);
        # Abaisser les signaux de contrôle du modem lorsque le dernier processus referme le périphérique (raccrochage).
        print ("  HUPCL\n") if ($c_cflag & HUPCL);
        # Ignorer les signaux de contrôle du modem.
        print ("  CLOCAL\n") if ($c_cflag & CLOCAL);
    }
    # modes locaux */
    # Constantes pour l'attribut c_lflag :
    my $c_lflag = $term->getlflag();
    print ("c_lflag: $c_lflag\n");
    {
        # Lorsqu'un caractère INTR, QUIT, SUSP ou DSUSP arrive, engendrer le signal correspondant.
        print ("  ISIG\n") if ($c_lflag & ISIG);
        # Active le mode canonique (décrit plus loin).
        print ("  ICANON\n") if ($c_lflag & ICANON);
        #Effectuer un écho des caractères saisis.
        print ("  ECHO\n") if ($c_lflag & ECHO);
        # Si ICANON est également activé,
        # la touche ERASE efface le caractère précédent, et WERASE efface le mot précédent.
        print ("  ECHOE\n") if ($c_lflag & ECHOE);
        # Si ICANON est également activé,
        # la touche KILL efface la ligne en cours.
        print ("  ECHOK\n") if ($c_lflag & ECHOK);
        # Si ICANON est également activé,
        # la touche NL dispose d'un écho local, même si ECHO n'est pas activé.
        print ("  ECHONL\n") if ($c_lflag & ECHONL);
        # Désactive le vidage des files d'entrée et de sortie pendant les signaux SIGINT, SIGQUIT et SIGSUSP.
        print ("  NOFLSH\n") if ($c_lflag & NOFLSH);
        # Envoie le signal SIGTTOU au groupe d'un processus en arrière-plan essayant d'écrire sur son terminal de contrôle.
        print ("  TOSTOP\n") if ($c_lflag & TOSTOP);
        # Traitement de l'entrée dépendant de l'implémentation.
        # Cet attribut, tout comme ICANON, doit être actif pour que les caractères spéciaux
        #   EOL2, LNEXT, REPRINT et WERASE soient interprétés, et pour que l'attribut IUCLC prenne effet.
        print ("  IEXTEN\n") if ($c_lflag & IEXTEN);
    }
    # caractères de contrôle */
    # cc_t c_cc[NCCS];
    print ("c_cc: \n");
    {
        # (003, ETX, Ctrl-C, ou encore 0177, DEL, rubout)
        # Caractère d'interruption.
        # Envoie le signal SIGINT. Reconnu quand ISIG est présent, et n'est pas transmis en entrée.
        print ("  VINTR: ".$term->getcc(VINTR)."\n");
        # (034, FS, Ctrl-\)
        # Caractère Quit.
        # Envoie le signal SIGQUIT. Reconnu quand ISIG est présent, et n'est pas transmis en entrée.
        print ("  VQUIT: ".$term->getcc(VQUIT)."\n");
        # (0177, DEL, rubout, ou 010, BS, Ctrl-H, ou encore #)
        # Caractère d'effacement.
        # Ceci efface le caractère précédent pas encore effacé,
        # mais ne revient pas en-deça de EOF ou du début de ligne.
        # Reconnu quand ICANON est actif, et n'est pas transmis en entrée.
        print ("  VERASE: ".$term->getcc(VERASE)."\n");
        # (025, NAK, Ctrl-U ou Ctrl-X, ou encore @)
        # Caractère Kill.
        # Ceci efface tous les caractères en entrée, jusqu'au dernier EOF ou début de ligne.
        # Reconnu quand ICANON est actif, et pas transmis en entrée.
        print ("  VKILL: ".$term->getcc(VKILL)."\n");
        # (004, EOT, Ctrl-D)
        # Caractère de fin de fichier.
        # Plus précisément : ce caractère oblige l'envoi du contenu du tampon vers le programme lecteur sans attendre la fin de ligne.
        # S'il s'agit du premier caractère de la ligne, l'appel à read() renvoie zéro
        # dans le programme appelant, ce qui correspond à une fin de fichier.
        # Reconnu quand ICANON est actif, et pas transmis en entrée.
        print ("  VEOF: ".$term->getcc(VEOF)."\n");
        # Nombre minimum de caractères lors d'une lecture en mode non canonique.
        print ("  VMIN: ".$term->getcc(VMIN)."\n");
        #(0, NUL) Caractère fin de ligne supplémentaire. Reconnu quand ICANON est actif.
        print ("  VEOL: ".$term->getcc(VEOL)."\n");
        #Délai en dixièmes de seconde pour une lecture en mode non canonique.
        print ("  VTIME: ".$term->getcc(VTIME)."\n");
        #(021, DC1, Ctrl-Q) Caractère de démarrage. Relance la sortie interrompue par un caractère d'arrêt. Reconnu quand IXON est actif, et pas transmis en entrée.
        print ("  VSTART: ".$term->getcc(VSTART)."\n");
        #(023, DC3, Ctrl-S) Caractère d'arrêt. Interrompt la sortie jusqu'à la pression d'un caractère de démarrage. Reconnu quand IXON est actif, et pas transmis en entrée.
        print ("  VSTOP: ".$term->getcc(VSTOP)."\n");
        #(032, SUB, Ctrl-Z) Caractère de suspension. Envoie le signal SIGTSTP. Reconnu quand ISIG est actif, et pas transmis en entrée.
        print ("  VSUSP: ".$term->getcc(VSUSP)."\n");
    }
}



# ----------------
# Canonique ?
# ----------------
# La valeur du bit canon ICANON de c_lflag détermine si le terminal opère en mode canonique
# (ICANON positionné) ou en mode non canonique (ICANON non positionné).
# Par défaut, ICANON est positionné.
#
# En mode canonique :
#    - L'entrée est rendue disponible ligne par ligne.
#    Une ligne d'entrée est disponible lorsque l'un des délimiteurs de ligne est tapé (NL, EOL, EOL2 ; ou EOF en début de ligne).
#    À part dans le cas de EOF, le délimiteur de ligne est inclus dans le tampon renvoyé par read.
#
#    - L'édition de ligne est activée (ERASE, KILL ; et si le bit IEXTEN est positionné : WERASE, REPRINT, LNEXT).
#    Un read renvoie au plus une ligne d'entrée ; si le read a demandé moins d'octets qu'il y en a de disponible
#    dans la ligne en cours, seuls les octets demandés seront lus et les caractères restants seront disponibles
#    pour les read suivants.
#
# Dans le mode non canonique, l'entrée est immédiatement disponible
# (sans que l'utilisateur ait besoin de saisir un caractère délimiteur de ligne),
# et l'édition de ligne est désactivée.
# Les valeurs MIN de (c_cc[VMIN]) et TIME de (c_cc[VTIME])
# déterminent les circonstances dans lesquelles un read se termine;
# il y a quatre cas distincts :
#
#    MIN == 0 ; TIME == 0:
#    Si des données sont disponibles, read retourne immédiatement le nombre d'octets disponibles
#    ou demandés (le plus petit des deux).
#    Si aucune donnée n'est disponible, read renvoie 0.
#
#    MIN > 0 ; TIME == 0:
#    read bloque jusqu'à ce que soit MIN octets,
#    soit le nombre d'octets demandés soient disponibles et retourne la plus petite de ces valeurs.
#
#    MIN == 0 ; TIME > 0:
#    TIME spécifie une limite de temporisation en dizièmes de seconde.
#    La temporisation est lancée lorsque read est appelé.
#    read retourne soit lorsque au moins un octet de donnée est disponible,
#    soit lorsque la temporisation expire.
#    Si la temporisation expire sans que des données aient été disponibles, read renvoie 0.
#
#    MIN > 0 ; TIME > 0:
#    TIME spécifie une limite de temporisation en dizièmes de seconde.
#    Une fois qu'un premier octet est disponible en entrée,
#    la temporisation est relancée après chaque octet reçu.
#    read retourne soit lorsque le nombre d'octets demandés ou MIN octets (le plus petit des deux) ont été lus,
#    soit lorsque la temporisation entre deux octets a expirée.
#    Parce que la temporisation est lancée seulement après le premier octet, au moins un octet doit être lu.
#

# restore config
sub restore {
    $term->setiflag($c_iflag);
    $term->setoflag($c_oflag);
    $term->setlflag($c_lflag);
    $term->setcflag($c_cflag);
    foreach my $key (keys %c_cc) {
        $term->setcc($c_cc{$key}[0], $c_cc{$key}[1]);
    }
    # = POSIX function tcsetattr
    # fixe les paramètres du terminal (à moins que le matériel sous-jacent ne le prenne pas en charge)
    # optional_actions précise quand les changements auront lieu :
    #    TCSANOW: Les modifications sont effectuées immédiatement.
    #    TCSADRAIN: Les modifications sont effectuées lorsque toutes les opérations d'écriture sur fd
    #               auront été transmises. Cette fonction devrait être utilisée pour toute modification
    #               de paramètre affectant les sorties.
    #    TCSAFLUSH: Les modifications sont effectuées lorsque toutes les opérations d'écriture sur fd
    #               auront été transmises. Les entrées qui n'ont pas été traitées seront éliminées avant
    #               de faire les modifications.
    $term->setattr($fd, TCSANOW);
}

# configure le terminal dans un mode similaire au mode « raw » de l'ancien pilote de terminal version 7
# l'entrée est disponible caractère par caractère,
# le mode écho est désactivé de même que tous les traitements particuliers des caractères en entrée et en sortie.
sub cfmakeraw {
    $term->setiflag( BRKINT | ICRNL );
    #$term->setoflag( OPOST );
    $term->setcflag( CSIZE );
    $term->setlflag( ISIG );
    $term->setattr($fd, TCSANOW);
}

# ---------------
# Terminal Codes and Escape Sequences
# ECMA 048
# http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-048.pdf
# ---------------

# Rappel
# En ascii (7-bits) seul les bytes de 02/00 (32) a 07/15 (127) sont imprimables
# En ascii (8-bits) les bytes de 08/00 (128) a 15/15 (255) sont imprimables (mode etendu)
# Note leur definition depends du code-page utilisee (l'UTF8 se base sur ce mode etendu)

use constant DEL => 127;

# Ainsi la premiere plage est reserve a du control (C0)
# Elements du set C0 (table 1)
sub isC0 {
    my ($byte) = @_;
    # 00/00 - 01/15
    return ($byte >= 0 && $byte <= 31);
}
use constant {
    NUL => 0,
    SOH => 1,
    STX => 2,
    ETX => 3,
    EOT => 4,
    ENQ => 5,
    ACK => 6,
    BEL => 7,
    BS => 8,
    HT => 9,
    LF => 10,
    VT => 11,
    FF => 12,
    CR => 13,
    SO => 14,
    SI => 15,
    DLE => 16,
    DC1 => 17,
    DC2 => 18,
    DC3 => 19,
    DC4 => 20,
    NAK => 21,
    SYN => 22,
    ETB => 23,
    CAN => 24,
    EM => 25,
    SUB => 26,
    ESC => 27,
    IS4 => 28,
    IS3 => 29,
    IS2 => 30,
    IS1 => 31,
};
my %C0 = (
    NUL() => 'NUL',
    SOH() => 'SOH',
    STX() => 'STX',
    ETX() => 'ETX',
    EOT() => 'EOT',
    ENQ() => 'ENQ',
    ACK() => 'ACK',
    BEL() => 'BEL',
    BS() => 'BS',
    HT() => 'HT',
    LF() => 'LF',
    VT() => 'VT',
    FF() => 'FF',
    CR() => 'CR',
    SO() => 'SO',
    SI() => 'SI',
    DLE() => 'DLE',
    DC1() => 'DC1',
    DC2() => 'DC2',
    DC3() => 'DC3',
    DC4() => 'DC4',
    NAK() => 'NAK',
    SYN() => 'SYN',
    ETB() => 'ETB',
    CAN() => 'CAN',
    EM() => 'EM',
    SUB() => 'SUB',
    ESC() => 'ESC',
    IS4() => 'IS4',
    IS3() => 'IS3',
    IS2() => 'IS2',
    IS1() => 'IS1',
);

# Escape sequence
# Si le premier byte est ESC, alors, celon le 2e byte, il peut s'agir
# - soit du set S1
# - soit du set IFC (Independent Control Functions)
sub isC1 {
    my ($byte) = @_;
    # 04/00 - 05/15
    return ($byte >= 64 && $byte <= 95);
};
sub isICF {
    my ($byte) = @_;
    # 06/00 - 07/15
    return ($byte >= 96 && $byte <= 127);
};
# Elements du ICF set (table 5)
use constant {
    DMI => 96,
    INT => 97,
    EMI => 98,
    RIS => 99,
    CMD => 100,
    LS2 => 110,
    LS3 => 111,
    LS3R => 124,
    LS2R => 125,
    LS1R => 126,
};
my %ICF = (
    DMI() => 'DMI',
    INT() => 'INT',
    EMI() => 'EMI',
    RIS() => 'RIS',
    CMD() => 'CMD',
    LS2() => 'LS2',
    LS3() => 'LS3',
    LS3R() => 'LS3R',
    LS2R() => 'LS2R',
    LS1R() => 'LS1R',
);
# Elements du C1 set (table 2a)
use constant {
    BPH => 66,
    NBH => 67,
    NEL => 69,
    SSA => 70,
    ESA => 71,
    HTS => 72,
    HTJ => 73,
    VTS => 74,
    PLD => 75,
    PLU => 76,
    RI => 77,
    SS2 => 78,
    SS3 => 79,
    DCS => 80,
    PU1 => 81,
    PU2 => 82,
    STS => 83,
    CCH => 84,
    MW => 85,
    SPA => 86,
    EPA => 87,
    SOS => 88,
    SCI => 90,
    CSI => 91,
    ST => 92,
    OSC => 93,
    PM => 94,
    APC => 95,
};
my %C1 = (
    BPH() => 'BPH',
    NBH() => 'NBH',
    NEL() => 'NEL',
    SSA() => 'SSA',
    ESA() => 'ESA',
    HTS() => 'HTS',
    HTJ() => 'HTJ',
    VTS() => 'VTS',
    PLD() => 'PLD',
    PLU() => 'PLU',
    RI() => 'RI',
    SS2() => 'SS2',
    SS3() => 'SS3',
    DCS() => 'DCS',
    PU1() => 'PU1',
    PU2() => 'PU2',
    STS() => 'STS',
    CCH() => 'CCH',
    MW() => 'MW',
    SPA() => 'SPA',
    EPA() => 'EPA',
    SOS() => 'SOS',
    SCI() => 'SCI',
    CSI() => 'CSI',
    ST() => 'ST',
    OSC() => 'OSC',
    PM() => 'PM',
    APC() => 'APC',
);

# Le cas des Control strings 
# il s'agit d'une sequence qui commence par l'une de ses fonctions
#    APPLICATION PROGRAM COMMAND (APC)
#    DEVICE CONTROL STRING (DCS)
#    OPERATING SYSTEM COMMAND (OSC)
#    PRIVACY MESSAGE (PM)
#    START OF STRING (SOS)
# et se termine par
#    STRING TERMINATOR (ST)
#
# Note, le standard ne definit pas le contenu
#
sub isC1_OpenControlString {
    my ($byte) = @_;
    return 1 if ($byte == APC);
    return 1 if ($byte == DCS);
    return 1 if ($byte == OSC);
    return 1 if ($byte == PM);
    return 1 if ($byte == SOS);
    return 0;
}
sub isC1_CloseControlString {
    my ($byte) = @_;
    return 1 if ($byte == ST);
    return 0;
}

# Le cas de CSI (Control sequences)
# Car il permet d'etendre encore la sequence avec un nombre variable de byte
#
# format: CSI PPP..P III..I F
# avec,
#   P: Byte Parametres (optionel)
#   I: Byte Intermediaire (optionel)
#   F: Byte final
# cad,
#   PPPP determine les parametres de la fonction
#   IIII + F determine la fonction
#
# En realite seul
#    I = 02/00 (32) ou l'absence de I est standardise
#
sub isCSI_P {
    my ($byte) = @_;
    # 03/00 - 03/15
    return ($byte >= 48 && $byte <= 63);
}
sub isCSI_I {
    my ($byte) = @_;
    # 02/00 - 02/15
    return ($byte >= 32 && $byte <= 47);
}
# On aura souvent juste CSI F,
# cad "ESC [ F", ou F est defini par,
use constant {
    ICH => 64,
    CUU => 65,
    CUD => 66,
    CUF => 67,
    CUB => 68,
    CNL => 69,
    CPL => 70,
    CHA => 71,
    CUP => 72,
    CHT => 73,
    ED => 74,
    EL => 75,
    IL => 76,
    DL => 77,
    EF => 78,
    EA => 79,
    DCH => 80,
    SSE => 81,
    CPR => 82,
    SU => 83,
    SD => 84,
    NP => 85,
    PP => 86,
    CTC => 87,
    ECH => 88,
    CVT => 89,
    CBT => 90,
    SRS => 91,
    PTX => 92,
    SDS => 93,
    SIMD => 94,
    HPA => 96,
    HPR => 97,
    REP => 98,
    DA => 99,
    VPA => 100,
    VPR => 101,
    HVP => 102,
    TBC => 103,
    SM => 104,
    MC => 105,
    HPB => 106,
    VPB => 107,
    RM => 108,
    SGR => 109,
    DSR => 110,
    DAQ => 111,
};
my %CSI_F = (
    ICH() => 'ICH',
    CUU() => 'CUU',
    CUD() => 'CUD',
    CUF() => 'CUF',
    CUB() => 'CUB',
    CNL() => 'CNL',
    CPL() => 'CPL',
    CHA() => 'CHA',
    CUP() => 'CUP',
    CHT() => 'CHT',
    ED() => 'ED',
    EL() => 'EL',
    IL() => 'IL',
    DL() => 'DL',
    EF() => 'EF',
    EA() => 'EA',
    DCH() => 'DCH',
    SSE() => 'SSE',
    CPR() => 'CPR',
    SU() => 'SU',
    SD() => 'SD',
    NP() => 'NP',
    PP() => 'PP',
    CTC() => 'CTC',
    ECH() => 'ECH',
    CVT() => 'CVT',
    CBT() => 'CBT',
    SRS() => 'SRS',
    PTX() => 'PTX',
    SDS() => 'SDS',
    SIMD() => 'SIMD',
    HPA() => 'HPA',
    HPR() => 'HPR',
    REP() => 'REP',
    DA() => 'DA',
    VPA() => 'VPA',
    VPR() => 'VPR',
    HVP() => 'HVP',
    TBC() => 'TBC',
    SM() => 'SM',
    MC() => 'MC',
    HPB() => 'HPB',
    VPB() => 'VPB',
    RM() => 'RM',
    SGR() => 'SGR',
    DSR() => 'DSR',
    DAQ() => 'DAQ',
);
# CSI (I=32) F
use constant {
    SL => 64,
    SR => 65,
    GSM => 66,
    GSS => 67,
    FNT => 68,
    TSS => 69,
    JFY => 70,
    SPI => 71,
    QUAD => 72,
    SSU => 73,
    PFS => 74,
    SHS => 75,
    SVS => 76,
    IGS => 77,
    IDCS => 79,
    PPA => 80,
    PPR => 81,
    PPB => 82,
    SPD => 83,
    DTA => 84,
    SHL => 85,
    SLL => 86,
    FNK => 87,
    SPQR => 88,
    SEF => 89,
    PEC => 90,
    SSW => 91,
    SACS => 92,
    SAPV => 93,
    STAB => 94,
    GCC => 95,
    TATE => 96,
    TALE => 97,
    TAC => 98,
    TCC => 99,
    TSR => 100,
    SCO => 101,
    SRCS => 102,
    SCS => 103,
    SLS => 104,
    SCP => 107,
};
my %CSI_32_F = (
    SL() => 'SL',
    SR() => 'SR',
    GSM() => 'GSM',
    GSS() => 'GSS',
    FNT() => 'FNT',
    TSS() => 'TSS',
    JFY() => 'JFY',
    SPI() => 'SPI',
    QUAD() => 'QUAD',
    SSU() => 'SSU',
    PFS() => 'PFS',
    SHS() => 'SHS',
    SVS() => 'SVS',
    IGS() => 'IGS',
    IDCS() => 'IDCS',
    PPA() => 'PPA',
    PPR() => 'PPR',
    PPB() => 'PPB',
    SPD() => 'SPD',
    DTA() => 'DTA',
    SHL() => 'SHL',
    SLL() => 'SLL',
    FNK() => 'FNK',
    SPQR() => 'SPQR',
    SEF() => 'SEF',
    PEC() => 'PEC',
    SSW() => 'SSW',
    SACS() => 'SACS',
    SAPV() => 'SAPV',
    STAB() => 'STAB',
    GCC() => 'GCC',
    TATE() => 'TATE',
    TALE() => 'TALE',
    TAC() => 'TAC',
    TCC() => 'TCC',
    TSR() => 'TSR',
    SCO() => 'SCO',
    SRCS() => 'SRCS',
    SCS() => 'SCS',
    SLS() => 'SLS',
    SCP() => 'SCP',
);

use constant {
    # macros
    # SGR (SELECT GRAPHIC RENDITION)
    GR_GRAY => chr(ESC).chr(CSI)."1;30".chr(SGR),
    GR_RED => chr(ESC).chr(CSI)."1;31".chr(SGR),
    GR_GREEN => chr(ESC).chr(CSI)."1;32".chr(SGR),
    GR_YELLOW => chr(ESC).chr(CSI)."1;33".chr(SGR),
    GR_BLUE => chr(ESC).chr(CSI)."1;34".chr(SGR),
    GR_PINK => chr(ESC).chr(CSI)."1;35".chr(SGR),
    GR_CYAN => chr(ESC).chr(CSI)."1;36".chr(SGR),
    GR_WHITE => chr(ESC).chr(CSI)."1;37".chr(SGR),
    GR_ERROR => chr(ESC).chr(CSI)."1;37m\e[41".chr(SGR),
    GR_SUCCESS => chr(ESC).chr(CSI)."1;37m\e[42".chr(SGR),
    GR_DEFAULT => chr(ESC).chr(CSI)."0".chr(SGR),
    # EL (ERASE LINE), 2=all character positions of the line are put into the erased state
    ERASE_LINE => chr(ESC).chr(CSI)."2".chr(EL),
    CURSOR_LEFT => chr(ESC).chr(CSI).chr(CUB),
    CURSOR_RIGHT => chr(ESC).chr(CSI).chr(CUF),
};


# read blocant avec decodage ECMA048
# return ($char, $fnct, @parms)
#     $char: printable char if any
#     $fnct: control function (string) -- see ECMA048, ex: "CUU"
#     @params: optional array of bytes which defined fonction params -- see ECMA048
#
# Example of returns
#   ('a', undef, undef) => key 'a'
#   (undef, CUU, undef) => key up
#
sub readECMA048 {
	my ($debug) = @_;
    my $buf;
    my $byte;
	print "\nPress any key\n" if ($debug);
    read(STDIN, $buf, 1); $byte = ord($buf);
	print " Key [$byte] pressed\n" if ($debug);
    # delete
    return (undef, "DEL", undef) if ($byte == DEL);
    # Character affichable ?
    return ($buf, undef, undef) if !isC0($byte);
    # C0 set ?
	print " This is code belows to C0 set\n" if ($debug && isC0($byte) && ($byte != ESC));
    return (undef, $C0{$byte}, undef) if ($byte != ESC);
    # Escaped sequence
    read(STDIN, $buf, 1); $byte = ord($buf);	
    # ICF set ?
	print " This is code belows to ICF set\n" if ($debug && isICF($byte));
    return (undef, $ICF{$byte}, undef) if (isICF($byte));
    # C1 set ?
	print " This is code belows to C1 set\n" if ($debug && isC1($byte));
    if (isC1($byte))
    {	
        my $C1Key = $C1{$byte};
        # Control String ?
        if (isC1_OpenControlString($byte)) {
			print " This is code is a ControlString:\n   " if ($debug);
            my @CS = ();
            read(STDIN, $buf, 1); $byte = ord($buf);
            while (!isC1_CloseControlString($byte)) {
                push(@CS, $byte);
				print "[$byte]" if ($debug);
                read(STDIN, $buf, 1);
                $byte = ord($buf);
            }
			print "\n" if ($debug);
            return (undef, $C1Key, @CS);
        }
        # Regular C1
        return (undef, $C1Key, undef) if ($C1Key != 'CSI');
        # CSI (Control sequences)
		print " This is code is a CSI (Control sequences)\n" if ($debug);
        read(STDIN, $buf, 1); $byte = ord($buf);
        my @P = ();
        my @I = ();
        # Parameters
        while (isCSI_P($byte)) {
            push(@P, $byte);
            read(STDIN, $buf, 1);
            $byte = ord($buf);
        }
        # Intermediaire
        while (isCSI_I($byte)) {
            push(@I, $byte);
            read(STDIN, $buf, 1);
            $byte = ord($buf);
        }
		#final
		my $F = $byte;
		#debug
		if ($debug) {
			if (@P) {
				print '  P=\'';
				foreach my $p (@P) { print chr($p) }
				print "\'\n";
			}
			if (@I) {
				print '  I=';
				foreach my $i (@I) { print "[$i]"; }
				print "\n";
			}
			print "  F=[$F]\n";
        }		
		
        # private def (non standard)
		return (undef, 'CUP', undef) if ((@I == 0) && ($F == 126) && (@P == 1) && (chr($P[0]) eq '1'));		
		return (undef, 'SUPR', undef) if ((@I == 0) && ($F == 126) && (@P == 1) && (chr($P[0]) eq '3'));
		return (undef, 'CPL', undef) if ((@I == 0) && ($F == 126) && (@P == 1) && (chr($P[0]) eq '4'));
        # Final Byte
        return (undef, $CSI_F{$F}, @P) if (@I == 0);
        return (undef, $CSI_32_F{$F}, @P) if (@I == 1 && $I[0] == 32);
    }
    #unmanaged byte
    return (undef, undef, undef);
}

sub test {
    cfmakeraw();
	printStatus();
	while(1) {
		my ($char, $fnct, @parms) = readECMA048(1);
		print "printable: '$char('".ord($char)."'\n" if (defined $char);
		print "controle: [$fnct]\n" if (defined $fnct);
		last if ($fnct eq 'LF');
	}
	restore();
}	
	
sub promptLine {
    my ($prompt, $default, $test, @history) = @_;
    cfmakeraw();
    
    my $input = ""; # buffer d'entree
    my $sucess = 0; # entree validee
    while (!$sucess)
    {    
        # clear le buffer d'entree
        $input = "";
        # initialise la position du curseur
        my $pos = 0; 
        # format le prompt
        my $fprompt = ERASE_LINE."\r";
        $fprompt .= GR_GREEN.$prompt;
        $fprompt .= GR_DEFAULT."($default)" if (defined $default);
        $fprompt .= GR_DEFAULT.": ";
        # initialise l'index dans l'historique
		my @tempHistory = @history;
        push(@tempHistory, "");
        my $historyIdx = @tempHistory - 1;
        
        # invitation
        
        { #sub reWriteLine#
            # mettre a jour l'historique
            $tempHistory[$historyIdx] = $input;
            # restore la ligne
            print $fprompt.$input;
            # repositionne le curseur
            for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
        }

        # tant que NEW-LINE n'est pas appuye
        while (1) {
            my ($char, $fnct, @parms) = readECMA048();
            # INSERTION OF CHARACTERS
            if (defined $char) {
                my $before = substr $input, 0, $pos;
                my $after = substr $input, $pos, length($input);
                $input = "$before$char$after";
                $pos++;
                { #sub reWriteLine#
                    # mettre a jour l'historique
                    $tempHistory[$historyIdx] = $input;
                    # restore la ligne
                    print $fprompt.$input;
                    # repositionne le curseur
                    for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                }
            };
            # NEW LINE
            if ($fnct eq 'LF') {
				#trim
				$input =~ s/^\s+|\s+$//g;
				{ #sub reWriteLine#
					# mettre a jour l'historique
					$tempHistory[$historyIdx] = $input;
					# restore la ligne
					print $fprompt.$input;
					# repositionne le curseur
					for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
				}
                push(@history, $input);
                last;
            }
            # HOME
            elsif ($fnct eq 'CUP') {
                $pos = 0;
                { #sub reWriteLine#
                    # mettre a jour l'historique
                    $tempHistory[$historyIdx] = $input;
                    # restore la ligne
                    print $fprompt.$input;
                    # repositionne le curseur
                    for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                }
            }
            # END
            elsif ($fnct eq 'CPL') {
                $pos = length($input);
                { #sub reWriteLine#
                    # mettre a jour l'historique
                    $tempHistory[$historyIdx] = $input;
                    # restore la ligne
                    print $fprompt.$input;
                    # repositionne le curseur
                    for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                }
            }
            # DELETE
            elsif ($fnct eq 'SUPR') {
                if ($pos < length($input)) {
                    my $before = substr $input, 0, $pos;
                    my $after = substr $input, $pos+1, length($input)-1;
                    $input = "$before$after";
                    { #sub reWriteLine#
                        # mettre a jour l'historique
                        $tempHistory[$historyIdx] = $input;
                        # restore la ligne
                        print $fprompt.$input;
                        # repositionne le curseur
                        for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                    }
                }
            }
            # BACKSPACE
            elsif ($fnct eq 'DEL') {
                if ($pos > 0) {
					#UTF-8
					#110xxxxx => 2 bytes
					#1110xxxxx => 3 bytes
					#11110xxxxx => 4 bytes
					my $nbOfBytesToDelete = 1;
                    my $before = substr $input, 0, $pos-1;
                    my $after = substr $input, $pos, length($input);
                    $input = "$before$after";
                    $pos--;
                    { #sub reWriteLine#
                        # mettre a jour l'historique
                        $tempHistory[$historyIdx] = $input;
                        # restore la ligne
                        print $fprompt.$input;
                        # repositionne le curseur
                        for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                    }
                }
            }
            # CURSOR LEFT
            elsif ($fnct eq 'CUB') {
                if ($pos > 0) {
                    $pos--;
                    print CURSOR_LEFT;
                }
            }
            # CURSOR RIGHT
            elsif ($fnct eq 'CUF') {
                if ($pos < length($input)) {
                    $pos++;
                    print CURSOR_RIGHT;
                }
            }
            # CURSOR UP
            elsif ($fnct eq 'CUU') {
                if ($historyIdx > 0) {
                    $historyIdx--;
                    $input = $tempHistory[$historyIdx];
                    $pos = length($input);
                    { #sub reWriteLine#
                        # mettre a jour l'historique
                        $tempHistory[$historyIdx] = $input;
                        # restore la ligne
                        print $fprompt.$input;
                        # repositionne le curseur
                        for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                    }
                }
            }
            # CURSOR DOWN
            elsif ($fnct eq 'CUD') {
                if ($historyIdx < (@tempHistory - 1)) {
                    $historyIdx++;
                    $input = $tempHistory[$historyIdx];
                    $pos = length($input);
                    { #sub reWriteLine#
                        # mettre a jour l'historique
                        $tempHistory[$historyIdx] = $input;
                        # restore la ligne
                        print $fprompt.$input;
                        # repositionne le curseur
                        for(my $i=$pos; $i<length($input); $i++) { print CURSOR_LEFT; }
                    }
                }
            }
            else { 
				# Drop!
				#print "[$fnct]" if (defined $fnct);
			}
        }
        		
        # entree vide ?
        if ($input eq "" && defined $default) {
            $input = $default;
            print "$input\n";
            $sucess = 1; last;
        } else {
            print "\n";
        }

        # test
        if (!defined $test) {
            $sucess = 1; last;
        } else {
            if ($input =~ /$test/) {
                $sucess = 1; last;
            } else {
                print "Invalid input\n";
				
            }
        }
        
    } # while(!sucess)
    restore();
    return $input;
}

#test();
#my $res;
#$res = promptLine('Enter your name1 ');
#print "$res\n";
#$res = promptLine('Enter your name2 ','arthur');
#print "$res\n";
#$res = promptLine('Enter your name3 ','arthur','^[^0-9]+$');
#print "$res\n";
#$res = promptLine('Enter your name4 ','arthur','^[^0-9]+$',('un','deux','trois'));
#print "$res\n";

END { restore(); }
1;
