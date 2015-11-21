#!/bin/bash 

####################################################
#files exe
pkequal=pkequal/pkequal
emu=FrankenEmu/emu.exe
####################################################

#input
echo "enter H0, Tcmb, N_eff (e.g. 67.31 2.7255 3.13)"
read H0 Tcmb N_eff
echo "enter Omega_b*h^2, Omega_c*h^2 (e.g. 0.02222 0.1197)"
read ombh2 omch2
echo "enter w0, wa (e.g. -1.0 -0.8)"
read w0 wa
echo "enter sigma8, n_s (e.g. 0.829 0.9655)"
read sigma8 n_s
echo "enter redshift (e.g. 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.0)"
read -a zarray
echo "enter output type (0: Delta^2/k^1.5; 1: Delta^2; 2: P(k))"
read outype

#pkequal
cat>pkequal.ini<<EOF
$H0 $Tcmb $N_eff
$ombh2 $omch2
$w0 $wa
$sigma8
${#zarray[@]} 
${zarray[@]} 
EOF
echo
echo 'computing equivalent w and sigma_8 ...'
$pkequal< pkequal.ini> pkequal.out

#emu
ommh2=`echo $ombh2 + $omch2 | bc`
echo
echo 'computing spectra:'
while read z w_eq sigma8_eq
do
pkfile=emu_z${z}.dat
echo z = $z , w_eq = $w_eq , sigma8_eq = $sigma8_eq 
cat>emu.ini<<EOF
${pkfile}
0
$ombh2
$ommh2
$n_s
$H0
$w_eq
$sigma8_eq
$z
$outype
EOF
$emu < emu.ini > emu.out
grep -i 'between' emu.out 
done < "z_w_s8.txt"

echo 'spectra written in emu_z$z.dat files'

rm pkequal.ini emu.ini emu.out 
