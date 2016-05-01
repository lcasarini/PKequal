#!/bin/bash 

####################################################
#files exe
pkequal=/home/luciano/astro/pkeq-sims/lib/PKequal-master/PKequal/pkequal.exe
emu=/home/luciano/astro/pkeq-sims/lib/PKequal-master/FrankenEmu/emu.exe
####################################################

#input
echo "enter Omega_b*h^2 (e.g. 0.02222)"
read ombh2
echo "enter Omega_m*h^2 (e.g. 0.14192)"
read ommh2
echo "enter n_s (e.g. 0.9655)"
read n_s 
echo "enter H0 (e.g. 67.31)"
read H0
echo "enter w0, wa (e.g. -1.0 -0.8)"
read w0 wa
echo "enter sigma8 (e.g. 0.829)"
read sigma8
echo "enter redshift (e.g. 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.0)"
read -a zarray
echo "enter output type (0: Delta^2/k^1.5; 1: Delta^2; 2: P(k))"
read outype

#pkequal
omch2=`echo $ommh2 - $ombh2 | bc`
echo
echo 'computing equivalent w and sigma_8 ...'
cat>pkequal.ini<<EOF
$H0 2.7255 3.04
$ombh2 $omch2
$w0 $wa
$sigma8
${#zarray[@]} 
${zarray[@]} 
EOF
$pkequal< pkequal.ini> pkequal.out

#emu
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

#rm pkequal.ini emu.ini emu.out 
