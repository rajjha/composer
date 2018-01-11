ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��VZ �<KlIv�lv��A�'3�X��R��dw�'ѣ��I�LJ�(ydǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�l6)ʒmY��,�f���{�^�_}�US9�vL1������˃�mz�t�K�Sx(�L��&�"��%)�.	IQL�S�L*y�2I����s����9�l#tɵ�C�9��oh9Ķ��F]�s���CM�N���u���3��pe����!wq.h��ZWnC]g`a[�jۉa{H�(�eڮ�P"C��E>G������mUqK�t�⾋mCև��9��a�7-�obi�M[Sb*>���mH�;b��l�D���6��O	Y�J�;'S�[n�S��]��q�s4���O��셤 $�"hA���lJ����(�%���h�N�sL�V0�.�@�JT�&���業�����z���,�nFѵk�����MY�6������@��ViL���X̲qK�n��Y��0�7-�oj�b�.�m����iv��^����ؿ��t2y�����/��ퟛG�@Q�3�B�vdh`���"w�C�ٞahF{�:\��qM��M�)�m
�7T�B�rP��MNk�G�~70���Q4��!(H���1Qt���	�E��)J��&O�I��(P>)f��qq���.�H�N9$�vQ�(�"t�)�4�R�Y��d�0�$�@��6GL�����t�Y��1��C3+�M�l>4vd��0L�ɠ�Q��X�@u������Vr��	2}@��.N��vI+�V4����蒀��i.�DxWMx���6����M�Fֱ�^GS:ȴ��|��{t�oP�D�6��RǨ��<J�Eor>���L����]�yw�	��"$(���Ah��MjNwj�X>�sg8A9 d��s�e�p_s�z��
����Ϸ�L��Ck:�%�i�� ��6%�g��"����ozD��"e�����h�b�B*�$�?��'S����?�����"
˓����ņ˲3G�5�E-H��dz$�M����r��h�m�4 �1��������V�^�l,�	�����~bW������]',�\9vI��{;��Vy�z��l�5�9� ��voC��x]B����(����5�������qF���0�̒��q~�R���(WJۍ���ƻ�F7��:7�a����fc i������[z|k�:� ?B�������l�?F����'��CU��edx�&����k���"��%29e����l��i���N��Dǵ����ѷ#�M������"��ƹР����b�>	`:E�*5;����L.J�k4��Ǖ!z��������qA`�*fF�7�a"�b�F��$L �B���E���Y�M6|��.�͵=L�l�	/P��:��mX��fU������ZN.����׌+f71���5M݉����%${nǴ��Bnp0�tM��t	�f��11γ�<虶�@�#�R��˦n*JG֌a�c��+ �<��|�5n��t5&�JG;���[(#?-M�(δ5A*��G�y����C8	$��d|).�!����ƚ�x�ݰ	��oY�h���B�s�����*�������0��Qf����L=�7��<�	�Ϥ�ə�_D����]�ؿbcȹ71�%���^����a�G~�9�O���Ŕ�����D�.t7m�,)_��f�b&;a�?;���r��OoU����F��CSՉ��ز�m*j�f�q!��ocx�oz,B3's^e��Ol��:���������E���q	��������S)���̤g�����
o�2�0���TVȦ�9�(fg���)�K��4PK�a�6��Ȳ5��/�v���:q���0�m;r߸��rs��6:|�-9���(���ň�=����J�1�>~ۅ>�����#�76�&dLeçI�k��8�R_�Z���@�Y�3�۔m�Iv�#86�^�$0���<��]ē�y����؅N��眛���:X�n�ǹ����ruec�cњ��L�"����D],��U6���~ss���ܜ��Z.7G/pg-��{�C o[^FQ�.|�!:[��|��]ry��/�'�ƜT/�-��d0���5��؝��\7
���J�~i98��%��w[A��V�����=�x�$��h�Z�͔R`����`�- ��ډ7p��� �T��3W�@:��y�g;��ېw;~�U�Ot�&����O�7���E���Ty���&����V�0���{V��XOBGdP��?S��lX��k츏d���v[�cf�䈗V��%���A`���h.˧yS��I��`f�U&N����v��cc:��	��L�8�%h�QWب��6K�����Fu���)5֖�1�u��� N���IJ z&��vc�ɡ���ۢe�Mw���˦�\�7=�V�+Oq�`Xo:������+�
?��'����O~S���"ʫ��h�Hl{�!��I�<���7�\�Mѓ(7��$r{���\���T_�s��0�B�'/�j�wZ?E~�^
6_���^���)�9��V�Yy#���?ȋ_��Y�F�_ ۅ���(/>��,8>���������L����
�|'HL����υXb��������˶�H��Q'u�c�j��'�~��Y�>��+�ҵ������Ÿ�s.�>B���W�V�܂)�g���]��9�+P��t��� ��T9V�*E%;ȒmHA\��p��+{���M��=�q�#b]B���W��-�bB~}nl��Or�c���>��l�m�Ўd��6��>�4��Ak`M�ռ�D�!�#��(O�Pmc�.�Uhn
�)t0ɲtM�Ԧ�&����F_�Roa�%��8��7:���� �4P	��{��f���#����a�����:�zoc�Ik`�C�Rv߀�C�'�L�N�nP@[06�@��M�9dǉ��P�`�������*20�,2(����O�֯zL^M�� C�\F.|d[�lQ�@�f�5&x6�צ��<��'�.�0<���+Y���C�٢�,�W��G`��٦A��>U���s!l�"q]d�N�)�c@��  �Q��E�&�S��k8 0p�n���=' 2�;2���X�c@	3�|���-�0C�g �1������`�Ȗ�&,W͒�����R��Kun4�����6�Ŀ��D���Y�.x������ó���:��)��tL�����ᦱY�M泉T-��8��͏0��t�WKڨ�E�-<����>���o��CY��m����a��Ox�EbD�G����xhb��a��5�qs'l�N�M�m9��ӯ1�
��F5���*)�1���Y�-A~l82�f�ٸ���e� ����(�z=цeJ�#B�(�j�X`�j��F#3C�T~Ǉ���z(k:=x$o�A<�����eF�T�@n�Q
�`�-����,!v��Đݼ��7�.6=��+wM�Dp:P�41Hۿ=E?f���/�C�HDg��v�I�E_�f���.�L�D�Qˠ*�N��XD�����j`�1ߕ�Z��N# h-lwa(`ga�s��>6����IM��d���d5�?N�I����#��L;���Ƕ&�0,u�∱����$��OxiU�a�6i�e�	������CҰ��{.N�ƇTC��O�d�`�M��1�Y��<����D��Kd��I.D9o�$< ú�P��0��������<��	!bW��ʛ9z�i��xn2�5�1�/���%q�)BQs�Yo>L�0���JW#1�������xw S���o}�1�)��s��8v1�@΋	�"�6mE��&;<�3N�E�����߱��Sh���?�Ί��Lrv�w!���w�=��w��{���?�v�W'�||'���J�K�-EP�Ԓ�j�R���R��\SbV�)�2���R2�ȩ��Ғ��.���b:��w����M"�H�����a��\�~��e"��.p�h�'�a�׹��ݟ�}9���H��|��O4ʽKW'N�{�_��7���0d�0�y �P��oD~�悊0L�;�!�b��{6���̳�
���tv_�y4N��O%�I��$g��S��U�\�:�\�����_���7����ί�#��_��?�����o�?�/��n�=�r����W�����ȱ;�أ��Me��I˼�J��L)>��6դ��3��ߑN)Kb�UA�-yqIT�� �"r5��w~�u��O��O�_.��˿��6�J����"�s?�#��G��C���t�o?����i��"���~�����>����f��ߏ|�~�_���o�D���)��j��
�z��R.H���*�r��_(H�ۖz��.׊������[�~oi����^�(����'�����Z�(��*5��j�ŝZm�Ի��}TjT��$l�
��zM\q��n��m�T�5ږ�W���W.=p����g���Q�a%��ΝJ���gT��:^]q�վ~�[=l6JJ%oR�_i�%��(�߯Ibe�_ٯ�+�e���ZP�U�*�t/߮��݆��4*�J�ĆV.������4hv�N���[�h�Z�'4`�vݸ�iv��"V+���J����y�ҿ��I�>z��moW\r+�^o�Ma�\�_���JO\9�z�k�����>_�j�e��(Քb�-����(dv��Ń�V�h�� �U�?�$�'��ô�k<ٵ�u�ȭv��EKwt�J+�j�k��\�he�z�%<����v ��ڪ��"a��oJ��D^��o�v+�"��ȧ"��r���+�(p�o��^)�8�,"ܵZ�Tn�ګ��?�:���薼��D~���K�:f*sX+f�����$�+���@C�u@Y������O���n~W.�+.�_Z��G�����V�JU)����څ��g����ȇ��ݺ�j,J�V3����z�WkUw��GM�T-7�蟜jM�Ě��К�R��0v��j"�:0?�jf�@�M�����s�YH�R�٩�KGR��e�Q8�v��z�ݓ��+��6kS�h���]�яv�����QKϣ�h���Ύ�]�n'�LFʇ�����J�/�6ܬlc�6��\�.R��\�:��Q�@�I��
�)�����mO�yZꢌ]`�y���-oE��^�07����º��.�ubd���3��9�!���O�=1�U1�XI�bHpÐP396�:�A戵fx.1@Gf8#Oa��N���+Y&�����>������4�"��<��*K+�˵-�!�x�Jg^�Pj7�����2[��Vg��١&��׳jL�b�  �O�1_VuJ
�A�E�qa'�qmdl]apJz�|�c-i۪�3�Uh),�f�0
^� )��
Wc$v��[k��XZ���6].���HV����
��LTq�Z+��t[����g��I��5��8�_�F���֞&L�4���/�>3�q��p��/�:Q#�SU�敹��)Vhj�CݎRmZp��p���v������B�2h�������ю��I�)���H�fG{�T�><iq��e�A3	;����b��Jb���(9�T{�=P{�z�q��P{�m���?�1�t�޾I�gpK��5�e�z���XP}�h;��dS��YE�{���ҕ�`	��)�x�m��V<���
A�xny�F>~�c�y��C��W��-�n�f�m���6,f���Hd��e���Sg��n �Z�Ф�Lq�'�Fȶ��2�>�,��1�$�[��?Q�c��F���~��r�� �x�{7ݔɩ�@/;�����m�/��«�������/�v��N����W}�Ӯ89�?A��Y�p��p������
_���-_����J7�nfJ7�mO��W��.^����v��G.+��wɻ�:T���
��k��a.���_�Ǎ|��o��m�_�==���G���?P�����RT�4�0`���S��%�s�-�C��
��ǘϡw��W���b"��W�=G5+��yd.�9�����k��b����8���]�m����B��b����M�������l�r�aA�W5v�T�Ԛ�H��/�ne�A4���Mm@O�1�%�W-S��jC�d���:�B��mg²g�ӊ��B�̑ru�q�2���ޑ�&��Y�'$��i���`2����0�}-`9ֲ��4`��0mO,r�"EE�8_h��{}>4�7�35�'��W��
L�]w7nvE1��鴃��ۥ�q�qP>L�%-��۱D��؍�5�CJCv��[�ofuS�xɑ��^Z�$j8~H��O�v.��I(k=�$I�����u�\o��z��_�����m����~W W�L�(���:<�G�ԫX����:v*?ީ���t}�?�;#�~���s����CW��n��A�Uƶ9Yk��B8tn!�2��00+�h�[�f�����X��>��f���Kűh�k�+c��Vݍ�qkڧ���ZjR���n4.�U��{KUU���2
_e�Z(s
�ĵ��2b9-��oN�
1��&.���v�O�u�2�����)��l{)u|N���P��`K���b�kN��t�~Ǖ���h��Sb1O��ֲ��m�e:��xY��ޘ��@1�3�ő��Cd,���F���^��;i��z�O�FHv��DQ7Sm1��ZAh�>Z�r�Jb�O7��c��	$��Q?N���(b|L����	t��&����I+��ǀ�{���.�0��qjܢ��)@M�61��Dx����L���k��¾h,k��zO-lTGTr�n�;C����M ���UQ�P�cD�'�P�z�XbEV[����"�pk��)U5�8rѭï���+U��
��^f�	�ޮb�1���t����l�>A	��Ń�d�v�bc}ۃ��Ԏ��F��%��~�1i��O�C��K�[]���4��3]�u�s�v�=�Ƨ_��J�'_t��}{�E[n���	���x�뿁~��溳p&h
����HќN���Ӓ��o
�x}��?"�����O����|�K���������?B�b�)��5	�sH�3��٤Gg�N���A�T�0ٲ�����Ni�P��>� ���>x+�n.У��*�?��^���:�.A��4�i1R�(��~��eHo�"�|*��Ϯ���1���%�Oy�'�����0��7�o�߻���k�s�c�`����Gi���=��1�
ޔޔ�T���z0{p�{�l��U[��	#�O�Ɏ0��_���~~�c������{�g�����k�d}� oA������� �|��)�.��0�?���׵���B������O^�?��� 3�O�Xf}� ���g��(|�#���@���X��� [� <���g���2B.�߱���!9�f��$C��FZ��@�'�K�������6@�ƻ�md�c?,r���{��@���L�_�30�)����/��߳����������` ������c$��i d������u���r��	���@��/��`	@� ��e�\�?�]����_=� RG.������?�j[������j[Y���\�?��3C���J���%����/��f��� � ���g0�������E.�L��2�cwF��f ��e�<�?�\���SB>��!Qqa�Lˡq�"�G�.�x���ʄ�Reqp��<������ a��s�����:���y��A�:8��͖�9آ�kB����*��C��"[�؀��$����^�`��\ZUT�"�J��lm���P�a�I��e�5T�ɽv-��v9,�}k����R9w ��D�,��'���Zӯ��X�?ú��r��e��I��A�a~!�~�⦲��s�<�P�3;d��	��������y�P�#;d��ׯ��`��^,�����e���X�WPq]i5Q��ea(�jŘvܕ��?�58jUFk���_M��a�������ee:E�Ɣ@Jk��ag3�ʕ�rM�U�)-k^{ [l��"q<X�dsfб��Ku.�����S����`�7#d�덳�?՟r���e���@����?@�e5�4`vȅ�#��G�@���G��_�ƭ�k�~��,Bn��b'V��ON�Uz\�ݾE���}Y�c��d�w۠��6�V��L��a�����zX��ew{�-ReݚŮ��%�� ��� ��Bwڬ�V]*k��,�Z�尶]5	�6�yv�0��:�^�4e����J��mẙ��Vs��4��ǲZ���;�\iA�:�@��o]_�2��5߹��4�t�|&����`��!�&:e�ѨE4����N�|���[v��#���JyW�x���])��R����zK�q�a�Q�ZLK��5�9�����@������>��F����|����H�����_RA*�������g��(|���0��4�*��
��CZ��������t �����_�������+��/%����>/���/[���Q��+X������K������?���`�?X������G�`�������������g�����/���߳��* ����_��//y����
=�ߜ �>�F�?��c��o*��S��!`�*H��o������9 ��Ϛ�Q���_�Ȗ�Aq��������2C��2C������?~��/X����� -$����Z��?�P�� �@��l��=����K��0�AnHf ��e�\�?���B����3�0�GF.��=�(��1<��y>��8��G^��Zu1F0�Y����������?�E�X�B�8��ęvv�4��r@��_N9 �M��Л�
o�j:��%�rJ$5��~k�����tdS��%H�6�2���^�*XgXB�ʶ��qc��Έ��z�|{�$��O�$�<�Ҋ��up�fmR������h0tEr&C�%�	��қ���i[�$��*�m��H@0Kj���0Q�&ɢ�uM�������wF.�r�� �#d��@q�,�������b�_��CJ���␩#�������� ��A�GP�������8d� ��e�\�?���!W��C��\�0��@�GP��|�ȅ�Cp��2B��o���h�r������l���ǐ���0�?��q��<���.[� �m�#`��m�@=�˴K �[�y�����e
��Ï�������K�������o����}_zG�/V_`V��R��>�.r���X��"[�؀��է� ���z����PG���ZȨ���n�Ր�q��Etq�b��jcW�ͻh����be	��W��j�'HR<\��e���@&�� -����[Q��j�w�[1�\�wMx�E�[�wqSY�9C�?�������L�f�<����C.��������˾9���?���<�?���C�������Q�n�2[�_�9bՙ�֣��j�҂��H[��s;b�6��b���Z}=�'%.F�5���N:D�:�]E��`���k��Z�n�m�QH�Ԝ���nOB����(�OE>��E��"@�O���z�>ŏ�g�\���_����/��������� �	���/#<���D��ܭ���i�6M�������bY��^��� ����y5 �c"�y@q�kk"��Ҳ�"P���š��&k�v�ÊۡU� �hh\Q�LE;�Ի+c8�r�n{{ªלE(�U��/��;q�x�S�%:�������<��^�Z�cY�]��έ9Qt����F·�]�AE厳gTT�_�5vzz�t��|0��L�T�!IG�_ֻ�u�[N�PŁۖJS~9/{�4�2y��73���޻a�Wt9l��^�S�b,��zhIx�u�lK��O����/��w�ь�k =ѵ���/b/H$��Be�vGK����H����9�!]�����:i^�Y���b��D΢��}w�	�#�3���;�m����.`�t�����Y���_�!�'����E��0ӫ����w��b	
���/����`����ﳞ�L�Ft��<O�Tʓ���7b��b�$IÐ	��x�����<��I0�W^������P��"~e�_[cW�H�6h����e�,�Ɖ���*{�"N�i�o��?l�E-�G���{+ux����������O3ݡɫ������s4���P�'�W��,N��� ��s�m�A!��MBJEDp}�f#!�i'�4�8�Ҁ�B6b"<	"H����~u��G�_�?$�J��b�T���A���e�c��&���懤s
�>��19����{]��c�2��r�[�2���R��?NB�WE z��f��������/���?
����������S��$/����x����?�����2�/M^���Rp�QP�G0���"���Cq��U���CP���?���G$�A�I���'���d����:8*���z�0����P���6�T�|e@�A�+���Uu��(������������W��̫��?"��Q��ˏC��'�J��v�#�j�#ÐP������,&����A���<�6�ˎ�%L1wK���2g.]�AQb�XJU��Ƚ(�y�F�'Y2��.�?F+f3qϔ�Z��i�d��+��x�<[�����?yjB��6���"�Ȕ��"*�V@�=���u`���߇�|��q̽lQ��ou`'���G�W3 ��)��Z����hV$��;�Z�bQ4��9K����6��B�}�l'�� .{k���ͲX&{���<[k,Blzi���ؖ�D�]�z!3��l�e+{����J�$�V���L�*��\�S���Ծ�F|.s���xy7��2ZѳA���+�L#�����v�����4{���ܝ��t��_V��뗴E=�ϻys����$P2s��~�\����ن��8jM.F��ɺ:^F.�Go��mQ]��q�N�_�}�8
6HM~T��[AX-�G����	u���Y��@5�����_-��a_�?�FB����E��<���i�}����	?�����G?�����j�㦤��17˕�r��+����/����_�*���_��$~�Zbp��tҚb���KmY���\'MG�{�Nz���O��ϯa�\
o����2��\���Ԕ�{��,����#>�TH>�w��"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H��S��}����jYK4��*�EѼ��^����)�.�v~p�$]���]��j�Y�Hz�.�YsFv���)�����2<Mŕ��Lƀ�d%ۆ�$���"0�М���ҙd���r$帙�ِ1�|eu�q�ΕM��)p�!6�Z?�gg��cl�����v��Z�/� �������p H T�����B���_�������}N$ �Q�ϐ��a�~����������r;�-H��Z��/my}~}�OVr����>��m�
v+�'5 ��0m�� ��B��� �O��L�y�ͻ� ��B��4�����U�s�N�m��E�g��9n4?/�m=<�\�aL�9-��<���n@�v����xG���̃��?����S����6dQ�� \�:^�=�X�Z/痒��XgKj:ؾ�>���+jGZ��AilB�h&c�^!�����x�0;3Ծ��B��q�����-�DQ{�hƺ���E},��V�.�T^yv��.ɃZ���+��_p���J ����Z�?��ʨ��C b������:�������_m��������$�(�C��H��>�%�����k�u��|0��?j��q�C<��0�#��p>�$�萏���`X>����( x.B�!�i��-q���`��D���o8��ݮd䳦0[�,���>$Ɖ�z��q�n%��6k��m���;������..�@�����y#L2�-���f�L{�0�H#�Y&O�����G&d�͖{8w[��'�D2��)����R��?��������%�VI��������?*����\m`���ף���:~���G�ɜ��S�kc���4��y?����3�D��?�e|�N��åuiҽ�C�vS=�-�A:��u�z���S[�6��A
w�z�N6'U���f�ߣ�M3)q����zޟ*������OA��"�����?�������C��U�A��A�� ��8�1`�"��ɇ���>����������O��#J�������K������W����ڵ$_�Ub.ǁ�[f�S���[l���h���df�F�X�
��L׊8��ƑP����vA{FdgƜ����^ئTaY�Y7c7�{N`�������˾�ӷ�O�N���ܶT�����Nʔ�t�Ӊs��~�,�#QkfY?���Hj�<q��:�tYe:�cָG{�E�F�Y Me �w
ݭ�2�g��㐚����:uO~:<���]��8�t{S�Z��N��b�oĂH��F3�䰥�t�a���?�o�@�� ����+^k�����?�A��H���������H�a�kM���Z�I������]k*���W��"����W��
�_�����?����?X�RS������O�$��Uz��/u���A�?��H�����������'��⥦�����_��u��X�R'�����a�`����/�j���C�G���a�+<�� <mAq�?���!!��A�I���?�h���
*�o�?�_� ��P���P�_i�Ǽ:�����@�B�L�!N�81A&t�B,K	��,�PA��AIƼ��\Bl��b�Ϣ����
�?��+�?���������Cb�,$G#Q>����Z�}a-��L�m���n��M����ᅞ��ZW}����c������z�٪܍{8�L��w����K�WR�>h��B������]�Vm���V���'=�	x�� ��?5|�@=Aq�?���9�����O����/��?���T����?0�	������������d�_���	��)���U<h�Ôb�$"��(ay�O��b8*�h>	�8!h2���S���������2�_���l�����<h[�1r�mS3�=�g�C��O������v�n��-��JX��T�&Gf�R	��/}̲�}���ٜ���M��29E��;��.ٻ�R�G.$�q0[��Msق��[�����Ձ@�o�@�MAq�?��� ���:�?�?��Ӡ�(@��������X�������A��� �j������_����?H����f�� ���\��W��D�I��>=�����a�#`����0��Z��`�#�@B�b��n�� ����Z�?þ�����z��� 	�y���?�����G$�t��s�����Ήt��d/�,i��Ϻ����v������[[g�{��)�{����������$$Oz�L�Ԗ�f�����҇0m���T����P�8�Q�]]ҳ��/B�_o5�M��Dڅ<�k��,S)��=�W���X>�{�B6E�4��~.ɃR�ſ�x��ǿ���_��SѠg�v!1�x�8�,Xr���d=�.�	��,J������P��=�D���,4iI��;&�¨��ت�uA>������ʚ��n�"�{�`�:����������k����A��?"�f�S�S��h�͂�G���O0�	�?����������U�_��_;����������x����#�����������H~���hz��8�MI=�cn�+���+����Lqq��SS�̓r����yaMCu����C�)��\t���������bѪ}���˄�O�#��䎢
g����t���2��OZK�ט�BZS��zxa�M#�t�Қ���x��I�����5��5̛K�-���T����!��g��,��g��g)$���"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H���÷�g��{�e-�|��)�)��sQ4������`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`����z�d�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-����Z�ă�O����:���\��]�=���v�W������#�V��!�E)C��1�3!�38#a�'tȇ\�QD�T�rI�NEl�P�	;�M������H�����K�7槙������bE^���E8mV�Р��6o��m��c����ȑ�y�+��o�l�f�y�e��8�g��nm7ݤc����[%��n���xoQ���VK�R��T��(����;;j۸ζ������}�[=:��Gn�<:�|�[W�n��׊a�F�ܵ�|�o��Z�rv�L6'�T��D��F�F��M��u�s��7�?�.=����MߧL�a���O�������x����h8n�SS�/=�����.�L�ϭ�V;�Q�͵��#�y��+�vsgW�VU1.��/��6�M����Ǚ\����o&�<�O����Q���|M"�q[S���l�l��L�ڬ�}h�����a�}�i�sc[i~<��G�D�{�����M�c��l��(=��_�q���H���9�����z��������������Y���O����� =���������{����;�
�_?7=���g��r�2w�)|SIU�������哜��ZT����Fˎ��5��; ��w "A{v� 0U���rY\h�F���; ��랙m�o�3s��4�Wɫs�i��O��ޏk���e�]i��*�7�z��q��S����o���n�*ߌw��z;�.w�1��+�H��t�}��/��q�y�x��l�4>)�?`��������iZ<L��MV?��P�twR_�=+}F������F�ݰ�ٳ#���OO'�7�}�����u�)}�o(œ�i�V�p�<���~bGu�UJo>>:,i��^�vlD�\�˗ّ}�8.j�K��`m�љ�3���͓��G���ǝq��TO%>N�:��;�������Um����|6����l~��?JzA��hbi��Cj�x�FqR�u��<���5yyA��ʧر�0�f���G�i�*��*KǓP
�~^hц�2�[v��H��4CC{��=b�2��kF�yb�*�2J|
B~.p�'x �1R�CV�@H�R�(�����v�1�1��b�1���M�L7ǤgZ5��F`ظ�a} l8*���94m��đ�������\�������C�o?�����O9w��xh�}0�g`?�J��f�)�A�0�vu��t�k�怈Yh �k� ӵ$<1O��8!'P����m2�@͏)6eb�0 u�[!���ûM #jjYt�b&��X�v�i�۶5D	�:c��T��R�^�H!�Z싫YL}M:.���;�E���``�U>�� �2��4o�jp�A����D5Gv�eJAlKS�`8a�r�W� ���;o��ha����L�o��^�oo��&8��6z'��@�]�B�@�k�����e92�g4�����l�-��=BF�f�$�`�ж���3M�ӆbP�	�B��jQ4Е��C�tKoKCAopm��X���T���:ȖCh�,D�K�%�_N�x�p�L;sl󉖋RH��P4��Ť*qH��� +H��E����D�G}��K�n�W�W�b$�����QQ+���l��Kyl��ta�L��4�a�A��τ����-����S�f�솼j��k	Nv�}GZE��X���(*��1~�`���u#J�T�H�t��u\$(Ewm�"�^?8���@*�搰u
�2�#l�;���S��X�F�
4T�ݱ����+��k6�} ��t�V )�
ҍd/�m?c*2�ݚ����k8L��PB��É��s'K�����J���7�\�lLU�K�2�p�@����
'����j*W̊�w��ܽ����Φ���J'3�T
�ӹtjs��Q�8�f��L��D����<� �`-mH� ԃɈY:S���eZ�*�ʇ��S�dld�k�	3�ךeh�N���b�U+_������^�9Jb!Xɛ*����>Ջ b�^kdZN�Ӌ��
�Gh��A�= 1���mYL2 �xV�YNOK|%��&�]!��+6���.��i��Mfw�y���4�*I�K)�岻,���������J3鴺�˲y��9�.�+�z�����$���Ը6uw����G��º��C`�Qˬ1i,J�ϳ�l�W���q?n�*�p�A�^m�/�����=�u���b�v�Z/V*�j�����KK���Z���9lT��SVݯ/(An����>3�ϲ�]���*�O��ZeO.���ҕZk��-	���ش����P5�@��I��u	�R}�t�.��1�XҚx�$�{r��gW�\�baI0����0�@��	0��,���ś��~q��������F���~P�\,�x^�|X��ˍ�l�J�tv.���Z�4�zg�5��B"�@/$qM�������AF�5�U`>`�;z.������p�4�GP��������E����h�@��<y����FC2�OhZr�f�s8/<��/5�Q�V�n�S�T��J�S,��=0�A�tG�r�|X)�>�7�@
VW���ݝ�O�TUӟX1'�����r�3�D�S�1��4椃9��,w��
a&�q��"b̷;3���._�[�p�']e#f���>9�ͥ�M��)�]���݊��L��2�;(�J��uM9�5��q�y�Đ��v��?�V쓤��s�]W�ոs�։��_2�����f����$�C�
$h	Z��e/�`�?�nP}l���OU[͏���H��]��di8���L��N	�N�e��;!��0��*��2�ٹ	UD&0,�k�}�9���G�V��`Z���ɧf������ϣ����f�g���Y�٬�l�6�?����]�����@{=���/ m�{6�=��{���?�QK5��>��뷱*�O>����2�����{���o��f$������4HO�l�0�2��ddi�C��{�ێG��\�A�
s���Ĕ��O��"(�{�t��������]~�Iq-O���Mk����zE����׌n}�9���8k��$�����Q��d4V�	��.���+�B��";"gmn<h�6z�RFD���	&����`ӈ�ņ�8��uNk������z�߉��h����![z�y�wk���W��%��$��5�l���Nl�H͆	uL�Qc}����ێ9��ǴJ���s3�������OO/����I�!������'�@���k
��ght����W���?�Xk`]E�B��m���ʥ 7�����vf#�����P�}I?�a�y��|���I�Q�)pe��?b~��/x2�����5삗��ӁJ��!7��t�t�:�Z�K%qR�������p=c��;#��f��ajC�2
�T�x�� �q��?S1߁�𓖓 Ti���F"Mj��h�]talA�� ׁ� [/H��$��7�&��/
Ͳ�l����G�����q�V�o����o���_$6x�{�^�Z�����Tԫ,6%�1D��F���hufd6U�?	HȰ����v�l�#�z�aИ^G@]��(B�b�a<ői�i��v������VL�S�`%1x��!��x7����u2��Ʈ@��uҿ'@�&W��?�b�:�"��8y����J�K�^�.�ba�j�����T�2�F{Y�^J��\�����ooȻ���Mh��d
M�)�b�V�l�p1�_�5��֫�~	΃!�4�L\��k���u>H�j%���t��!#(P��;Rm��I�]��,v1���m�o�^� Z Q>�Eߊ̛�3-���֜�6d����L2)���a���{u `E����+�؉p�O�u|TC��7�o�ۜ�4���PM5,�-��]nw�b-���͕�����H��F�O��f����V�<��ev���RD��y�0����r�ϯ�a�۵:���%猹�푦z�s�nF�ຠ�Kp���1��4�+Vt��ii�Ɩ�_�G7|)��
I��0͑õp��}k�	�4`~��[;�%�����fc��Q�r��xfnK�d�T^��\�4���T�u��>�'L�[�X��/����G߷6����?
�Je)�&Y>��%��N&����e=%��Qv��ˤ�s;*M*�lR���<������lv;a_E0�ʣ`mk��~�|j�x�#[h����J��<��%��(�����U-���(�� �3}��Za���h��Ib.��	�i
8Ǯ�%��gK[D�ɒ�1~�ak��=h�����إd��`,2�0�뫌������-��:��Y:&dAUDwjE�;"��� �x0'I�1C6�Է���m6��hh0����B���rgL��a#/�����}�M�O�\��آ)\��V�V����۳���f��1����
�QG�^SM�I0L��2}�Nn�Ҵ����o����������O2������c�uǟ�y��?P�������ϧ6����~l���gl �����p�������qG$�bG�H�![�洐�M���4�/��,ɩl�18)�v$�H+�z���h���_��7�N�չ��N��F��ө�-�@$��	z�ۢ��[gl��+`'�҈�c�1vÔ%gLũ>Y�w+ͅG�q�ə�=$�����y��&x'KP�:�7��>z韚�����E�KD7֝��<�����G)�M�~�������
O�|
�&�����(���?i�#j�G<��t>��š+P5��������)_�GX{�!�d<��|��:�f\ߧ��u�uژ9N�U��u�ߟ����ִ��ʧ7����{��7��[�������*�O�����l&�����&�7�{�o���(�b���z�O-�H�ޡ�a��,⊐F����j��dD-��~^��N����Աٟ�/�#� �ߗ�^f���Ц޻w�w��".�ء���p]���Ն���2��Cs�3U��~�y�+Z�[���g.� QXЮ_�8�ر���	|�n� ���m��V���x'	Z���}��*�:Ѹh�V���1E94�{��J
H��3�G�����g���J�;J���5�c�姌x�W^Dơ ��{`��J����"����q�W]A���x:�9�F�厺	-X�H��5b��"�H�	��@���(��C �<�(���<��5������	��G��jT]�q�H�@�_:��Z��W ��fy���j7��<Ym���x�&@�=���[�B�k����ki�ď^�M�J ]�&�+�6�z��L�xR=)U[���S�r8Q�|�@��+��	��I��֧;/d(�����"�)4
xlԋM�O�x�
"(�SH�$,ӶqI�w[]C�P�YƦ���qhMCF����L9��<��4^f`b�54
�qB�D�;ogOS�#�k�7�T˝Z�>���s��3���_Z�Ǣ��|��aSQʹ8�0����?�b1�G��\3�K�W���/'
�M:�I�0������R��ĺ�dW���@�Q���(_��^���/d�,"�.���l;|Iy�:��n�:���8���1�3W:��x���.�^�v�B)�b]�C��0������e8���3�ׇ�2��ơq��,0��p��ސQ73{Ho��;\� �1k������wm1�ciy�w�����L���Ҕv4��؎/�Ʒ$Nb'N��h�r�q�87'N2�< �]-���j��+�+,��@�yA<��V����*u���$L�k�����������������sr�&˫���Û��U�9�<��7�L�!/�ժ�l�U�����u��7)��z}`j�w[��.w�c�[6ᵼl��>���e�ڗ���T�z�O��U񃥗����W�n\�k��<���z�f�z'.r�ۋӎ���f���R�'�����-3�n�^����[��yP]���s	�lL��f��ƅ��¿��C dߟ;M�sR7Y�u����cAާ`
=f���<K�h�Ů��h�-�	�Y_����D�K�u�;�K���?�7Nj�O�O��9�Q�m�툃M��7ϳ��`o��|[�?�X�;・����?���AC�H����� ��V ��6����ۇw��?���^=�|�C=R�k�R�F�!�5���(�Q�P%5Ct���*�jF��T�(�V�8��m�����!�
xicB : /������8^�ހ^��՟ÿ�}��ɋ<�up��:GG���:BoA�|���y���ͫ�g�x/?�&t׫��u�f����O�Y�꼽�y���z����?9��6.Y��"���O��`�o���A$���?�������o����6.��}��������_��C�'����nݻ�qŏ�\��u���0�o��h��k��E�$A�G0�Z� �N�\���j��x���(�ТZ�x�xTBo��?��������?��O&n�S�G����.�C�C��xica��7�o�q����u�{�/��w^?����b>��}���?�_Z.�@wg�C�4�r�ei��J�-s�j���!�JR	�T���c�f����2G����6\'o�f�h��7�"2���MQ>/_tU�k"�]�V�(?�W���O�����Dlɸتh^�tQ&�ˀ�'�N.�k��*(bNt�ŭ	�����I�ҡ�Վ�se7FϏ%xQ�[����lV;R��Jc1�vc�B��0���&�N+�WGe�rĜ�ƍy��U���W��]�-'�	�YZ^'#�h���̓��"D����0$�R�)ө���p:<�+��*�ro�Bf��T�g-ݡc��\�%B�*h�b1i�G��X��T«�75�!��s�c�;"]��D�L���v9w^YYTV]������Sd�/���Oy#�:�H��Z�*I�mv1b,��4]�ۍf���N���K�h�`��V�R[S�xCt���Z�,d�Ub2z;�׸�,��/Y5'�q1�:9:nG�q�J(��������@n���0� ���^:���l���I�Q�.H�i=�ħ�iv��%�I*_��$�<Gk���<*5�M��e�&	�}b &�wݢ��:Z�ϟ�L\�P>>��&���ۓ�"��1)��r����k�bNI2	;�.H+�6�Z�NŴz�4q������E�<)�z6GT0~7�TKQ��Hcq����]�ۄ�]!G<�T���t�Mu��N^�	Z&3��!�hO`�6:��ݠE^e�ņ)� ,o��JYǢڌT�iWB$'�z�.�n����!y<Et;RrZ�ƺ|O�W��Q�
b"����(r\��}Q�w��b>A����H�å%��b'�;��� 9�i�B�*��c��Y���D����X�Of��=7=�/�k��˞뉞��� ���'�����+�Sj6fYbdù8�E&�U)�d������Ǆ.UL��z��Q����>�͢@`1U�*9תS�� A�=��5p��\����y�CV�t#��k�Ryi<+eС�%2ݚ�H���i�}���'M'��A���Q��t0���̐Q97f��eN񈓌"x��R��ǜ%%ڨ��3��I�53�eAnpZ��h��q���̲��^~߀~�3	߄�;���/��[oK�o}|l�]����x�3�����F��Nk�n�v=v
�2��g[��~�fxY/��$��Wz܁�_X�7x}y���w.9��7��΋��	��k`#�=����x�>��>������_���R*K�<*�k�2_p��24�,S�J<�+�F��ה�-�c�_�|==�knlA,�����3���,z�s�\�:Z�&s�u�.o,��uN3pId�g|���P���Za��RX̱�ƕX��#��O���%�����걖("�ǩ:�A�L��D���ي�j���T�ڰw�I���FqV�Ē�)���.uAI�3���e�\,k�#Y�p��Q���i��n��B�d����]�s�l2,�U�Y�d�a�j#b!�t�x��1�dʕc�n�H���N��Ґ4��I�%}�Ζ�UDi��N��Db�R�� ���a���5�)!�X�X=x(s$�dl��Yz�2��E����5A����T ���߼tҰ��\]+�r9�#��t���3Cc�������S����+��>� �fta� s����`=���)|D��S��O%�=���W&,ʸu�[h���tם���:~�./����v�h����D8�4!g�ȬUw�f1�uƆfe�Y�*#�P�d���R:jMY���Y��a�ɥu���:
񌫾,di;j��v�"�D�ܗ$��#�uZ�݅��/eV�i7��,-��]�K��DĻ���#����1
��f?��tb� (�����Ɠ�Q��.���&-j�T����JAO&�mE���d�'inG�WD>1��o���E�x��&L�'�F͞����H;	#0��2ލ&g�O���sBR|A2=$�4��=�d�#��t��E�3Z�[�+H�n�^
�Il�?Z�K0bܝp�%��0�z���D�̱�0����J��M��r��O�Y-�Rl/4$�|�Y<e;<5��p�ǳC�QD�㊜�����Y4�/Ka�q҈DX��-4�k�M�5�D��@+�r�@!�tY�GB�ܷg��#����FrN�x����7 m�)�]m��|�A,������"]Q�R��d�q`��H7�,L�T���'ex�u���G��>�a�T�TjE*���dZ륑c��W��y:��^�
���>	]�W?'r�2_�������R��Cg`��C�`U���]5W��������/��h�U����[N�ס���G�!o=z�`]�k���=/�+Ћ�6z��y�:�BV�,���!��tEoҥ^��s�&��ІM�6h��D5;�j�����w�W���i��<!�F�/r�Gw�^]W����7#A8t�z�6���";y*��ſ 7����z}�d_�]������#^����m��㿎
u�6.���.����_|��|��z�ѣwV'�N������Α�h����gz��m��o������.=z��#?2�'�ߌ9S��M�yM��}�Iѻ�V�C��>(�
7�#�7�B=�o�zh���о�#�{�7�DywqCW�C������M�Q�z��繣ڏ5�G��{�������6�w�\�?���~����`!`���gԟX���۽0��e���������noT���xaK���_� N�� �@��6���ʤ�A�/�l��Hw��8USbIqR4F�!�'����D�n&V��m^��r�Ҩ�Q�n��zH*�n����t�E�Cӝ�T�g��q���w�W���l�O����lؗ�q���&=y���q"����`�^�U/تw��~�~��Y���m`g��������9����o���"�˦(���A_��0q��|�P��t�Iu�0e���]P��8��t)^������,��mt��tI��s�1;�U)���,��dhV�:��Uu�.�
mu*��)�t\-$иi�͢�v�#%��V�Ü:�������]��4��خ�����3�Еڸ��A	������������p���u��'�LF�`���g1�����6�:���?���_�����#�ߎ���"e®�2�㰍�r��<��6��O"g����/R������{��?�®��O���{�����>������]�M�7�C�D�����#�|���l���5m3���~�{=}Odα-��p�?���,���a���}Aؾ'	۷��t��|���@��
v���!A���"���o�o/�;g�G������9,l	{a���Y��lA� �s�|�p����O�8���6�K�ϱ���#���o�o/�C���H���������`����?y��?���� �R�m)ȶt�lK���O{����ΰK�O�K�����[������aO�?� �#����w����������`"��v�]�m}:t�=��w������}��rf�?N񿶂����"�W�d���!$Q�6(T�j�ވDq]'�:RÈZ�Q�4���0�&�o�ի���>��8k���o�y��/1���L��\u��e0�I��gz)��45�T�`8c8#���/�h72�N�e5�����+�6�`H�$V�'1x&rZ��[xU,�Y#�;b3�)ٽ~�6�lc*�2
Ն�^�||����;�}��A���aW�߱��>`�`�����A���a���h�=���Sx~�����Ӵ����(�ˢ�p���K�B.U�EW2��aɑk��r~e���B;S�2J�S��9��t������x�1,��H46�H)�����ZOjLoM�x��o%��VG��N�Cmʱ��wU�{W֞(�m�5����<-�pq.@QAQq�9O���((��4Cw:�����)����c��Z�j���X�9��-E����>�E��@D��
�A��A�����+h�4`� B�	���@�������_��k9q��&i�A��ԟ��֕�O����?��~���V��&����Ư7ۨ��m*m����\���Vw����Zw3@~���Ò$k�qPF����R:�P��&Q.�lcW��:��^�I�!�u9mwm�h�}]��*������[Y�6�:y�r]�x�M�N�����C�B>�4׫]ﻮ>h��c��_Dߎz�fۨ��,�E��R�Q/4�u�|Uuf��z>;��n�0�T�C��Hh)�ix\����7���8�3�BYU�TJ�|�^^��κ����V����Q�V`ҨU;"��|z����ל���9	����w�?��p��C�Gr��_4�����GA���q '�C�G���7��� ��0��?��G��X��o�?��/L���Ür��k�?��en�?B�0�?�y D�������C� ��_��B��?迏Z�a�� ����	���8`���@���7�.��`����_$�?F��_E����'��'8����?O_�����x��ҝ�?���l����˳X��?�����w��(�����E_�/�������
C���!����p��o�B���()���}�x����X �����������_��0�p���b�)�����#����+
���g�6�G��S�q��?���u�Z��b�G};�4j�L��֦ܯ;q�z���W�?���܌��S8�`�Y���L�j@��O�׀ȇt[U��^7;mȖ���(m��q'ium�v5�%��e����O�(�Lm�?-�A�X�ļ��t��b�;��k@�kȿ���E �T��ռsq�Ʋ4U�DuK=��|2Mq]�&[����i5Uk�@+�[�4!UV����,df�z@V{��yʆ�(��hȸN�O�_�οD�?���������4�,�����#���;�?!��$�?4��"������,������?B�G����
���P��������_H�h�D�8�/���?B�ǯ"�����P��[��4��Bp�� ����$�?������� 9��+� N�"H�Q8�h���y�؈eiY	&�h$�Q$�/��"K�D�?����g	�ω��������ow����o�=���Ɔjk����f����f���qn�4���uo�u�4��3~-���8��Tߤ�=�A̼���q�U��p�)�iG�W�N��fȖ��$;d���I���>^,����|��B��0��gyƖ�g�]�fG�8O��8Q�S�M�~j�s7��{7/��NHX���gq(t�ϖp�[0HX���"�������~����/ŗ	���8�I�����t^��f]+OhJ//x4�kκ�4��ú�r����>�?�[9	[��e�$��Fs���J�4�J�S��C��K~��''g}�s�]R����Zb:��r�&�U�L��qͳ��~d��7�_���
_��-�}�+�w��������/����/���W��h�b@���_AxK���/����i�������=dޖ^�ĺ�z����O���H=��(-�t����mrK�����Q�:��r��`1��}�a.�I�e.��e);�bw��MW\�^R��,�f#HҺ_c�q�ٶ�弢-�?�<��4��5�I�i��j�#Ms���_�SSu���ە���{E!Sa/9��,�����aU��nE.K��(�{]�s�����r�+6V��Y���e0~�#���k�z�z58@c�L��t��I̠"���z���u�SO�x|r�^�ɭ�uh6)�"�E(Ys*���h����o�Ʊ;�F|��F
��	Ə�� ����翜�Hp��$�F���i������Ӌ`��o������DQ��0����/���_@�}��/ 1��P�e��"�e�'��x�H��0�}1HF2}�Jp��X�2��FV8(��@��o����������_�&��	���j�v�:*�(\6JG���h=o���JP�=����l���we��~$��̽�꿰�����;y������E��?����pS�+�,�?��ɿv�`8�K�|�'GJ��<̋��<K�b�)�$_��}�A!0����^���X�'��.ƑZg{�=�>M��n���[4߇��/�+��ӱ>��۸�˴2�;q�kZ�߯����f��� �Y�a����������a������/�����_�����5������{	�����f3?y����ث����� ��1���OL����}z��E�N�}�����W� �� ������?������q��q(�������M����	��uLї�K���p���_�� �����/ŗ�?���/��� �cA��o��1��.����������!��o��y�����������T��R��+�PH�^�鯒9s�l�iNU�R�������ٗ_t�8U4���Ƈ`%$��1�5�1+v����-c|�Fa����?c[�yj�>W_�]�u�*���s��wPQ����90ʮ�ߛ��N�z��1�ȫ�S�]^p����W$e�l����Y�^���eq���b���s�~�V��vZn�Sc,dyo;J�sΜ����2]��Zm��A�VZ���\�:�.��������)r"�J�z���j_�]�zMe�+[�"^����ՑIi��'�sP���d/W�"�j�*�+vce˭�q�͌}Oݢ�ׅ|��Ńk7��h���ɖ�:�;��Q��r���Ko�i#d�vFy)�K��'�Jq�W�I��΍�>�X�px�����uTs-���{�c��5�$���r?�?[ ��wo�7��a�/��k�(�����#���?�?��������`�A��������������/�?8�ֺ�N��f�6Ci�1K���+8���/����S9��?7J�Y�X�U���g�Δj��>1�M���3�X�gѭ��������sͿ�e��V����b+#�5�q�"�������ߩ���?U߫��j�^n5�1�n��o���F��\�D}J:��V[7����x�5�FM���`Kci���t%+�'�8捓�y��5m�7��r��Y�{[�u�~��U���}��py�����P-m����Y�B�:�E�Xm�U7,�j��JU�gl]���mu��e=�ѱj^�r+|�pE�b�[�7
y�a����qI�-!�^�W�I9���7+�~�l�#A��ۊ��Rþ]k#zv���t�8^G���]�"�s����� ��� 6 �����������/�������Ol �	�_`��C�7,x��w�������q�����ό�8cz٩�O���l!��?���\��P���� P�`j��� P���z@~�H=��?��yw�z�ѹ-��tǔ�{�Ҙq�l&�=/������Q5v1�'l��ú:�R�l`�|�C���/'J{�c�M�oP$���9 �9��4ިQ��*<�(�3��y�b�%_k!u~Ι@�Xb�M��M���9��Z;�J���FUCf����R����z4���I಺������zЗNm����j�g�7�Z��MM�HG�"�*��,��ϲy@���_���%��� ����D�?���@�C  7H��p�_�����������
D�?�N�����ExJ��.�_ ��m�G�s������cI��01�ӡ$�H2Gˑ��Q��r��,r� �DO��%������x^�`J��A�ߛ�����7���fSklfee��Ej�R�t���9X.˪�N�]����o�ݡ����Iloq���T:��Ue�)�aL���wr;�I�.C���XsW������{-6dQ��uoj��B͞n�
��U���C���P���-�зP�����+D�?��(�����v��E_�/��_q����p�p,e�^^-�	���QX��ۓsǼ|g�i���k���z�"��K�\�[���M��l���h8�)g� +�̱jm��h����y�����n�[[o�86)�9�5���]��SCp���*�X�Y��-����>��@B�꿊�A��A�����+v�4` B�]��������x���Z�����O�o�\ePى���M�Y���'���O�Gmw�v�6��&����:����\��v���K�a�lE�[%~L�����v0�j�$�t�l�����t��\���s�l#.u�Ӭ�	�;�rR���ԭ��OW������U��׫j��]�;-6���S�M�Y,�b�Z+�q;t�C_�}�9g�z��W�%˔3lq�V��^#�-T�p+VM:��V���e����f���P�ЧV��qu�{�d6�:Ӭ�p�1k��63�ˬ4QTv'��P
�[nQ�։ m�����$�?��S��������J2p������;��X@�w��� �CWR��_4�������+i��������W,���0�����B��x����L���`�� ����	�ϲ��v��/D��'��A� ����C��?迏�0�T��������_��?�x!
$��{�_x���0���������+����N�?�>~�x~r�������<�H������� �Á?�������_���< ����C��P�'ܜ���WL������|ߧy��&h°!�HA�"������;q$���O�몝��AH�w=o%!s߆}�<:!ց��5�}2%a��ˮj�)E�v�T*��eD�2��d!-�*I�X��(5��SRF���>�N�����|�Sl�}<���Fٛݗ��p>u)"��T��	�|�g&��>s��������:��|����ӹg�5�,G�wW�.��6a�i����}� )q�j��~��z����q��j���l!ǌ
]�A��B�����)���}�?�������`�G�p�t��������a��J���{��{:����N������Ӥx�_��/����;n��y�����A�P�Ts�ǐ̒c6��v0)R��tZ�����lJ��,��
�fi�e�P&U��I�� >�N��������3���ot��M��%��q����M���נ�C6W�����s���]f�egΎ��p�6{4���1"��u�2���ij8��)���+e&T���pjk��=1JB�&spy#�0Y$�|�+������G��8K���T���3�*��A����'�O��:����<-�b�������,���@td��?yd��?����j��O�9� ��_�8"������?�,������?~?�t(����(:^�?��?��?��?��?���s�c�����	����߆8����m������������������ ��)�������b�� ��������vWTw�]n��*���73=��o�������}�ѶN4�k���=��l�z�\�Ԫ,p0nFM����]{^���.d�d��ΔG��?g+�>S-�e�O	��|ּ+2c�1�myA*������5�	�{b׿�\���^�	!�8ί����Z~��v�xb�ǿՍ� ��Vy�U�*�SD��e����,C�0oAs8�Ն���i��,��"��t��]��[����hĄQ�^�����s�z��Y�Z^����?`:	�/�>����B'`�m}�ؽ��Q������I�zO�7���A��?>%��t
����(&��A��O��O��O��O���G���>~����(��m��$�?���F�����?��8:�?^�?������W������^�����j�/��V�ę�z��ʽX%j�,��'5�߯��{�:�ZW��'rј#�ܓ�0�z�=���{:_$�y�����ʮ�]�&�`u�bn=����d"��Ψ����*�9)�S�T}BT�{3���R�u�>-S�n�lt�� �M�4r�F���c?� 6���P�c����Aەin���;}�#�_����Jg�N�ַ�K�~�+�i���'Ġݽ�Kfu6�F�7J�R�Ԏ��k�-�|��a�NMm�3#F\5�2�v�j�c�����Z?ے��j��ޮ��8+rS��	N���֬&T�2?�G���e>G���̯���T�R�a�B!Sө�t��$��Y�BC'p���ĞPn	�SieA����2Y�>��st���i�1=��[
jR+k�t%c���k�*X�B�~-�z�_+5%R_L�]��^����1�������g��ǃ�	�3�v\ˆ�����_��;����Bp�W���N	�ձ�b�q:�*d&���i�ɦ�t.'C2rVf%�(t��2�BѲB�JFI�9Z&!#���������z������2]��L���XNvi��V�9�;��~iZ���irQ���oe�j�\2��R'^?=ʉ��ZXx)aQ$���Ȟݬ���bZ��I�c�y��D=��U�ds-U^$��Vt=��*Kj)>���t
�|������kċ�G�S��c��xt���q4:��M 7�؝��)���������-��U��9�X�Cx��8�-r�ެj��9��J����b��4ľ�5�:+��N�:��_%�>9!�~GWa5bșF�5��/�|��9_>_{���`�g|GiZ"GV�dW�c��t�?��D'0�+RB����_�N���x���(�����������Ol�7�ۀǠ���X���G�c�����7�G���y|���1nQ�$��o��*�uq5|���:=������y��`�Y[�?���� b۞ݻ ��J�o(Sn��J�M ���Z˱Ŵ{.y^u-�ro�Ԍ���1�</$�ʵ_��i��o�{�:���~���p�zΦ�ג�����!�eOsuלO���ڨ�ǾhQ�9�A{���+�~�G���kb�G�'�M߰a�AI\)�iMX/.�|^Φ�]���sB+g����i8u�Wqj��@�jMj��P0yctS��5%�M���N���-�,�+d���dV����|8��x]���IX���]�Y8�F���)�%a�jt���wn�J����������`=�^W���i4���?���ƫe�����v�J3$��!����ֵ��|]ً��q��0�5A|">�N3sQ�h:�B���:�/���	��$ʇ2^�!ng[�v`j8g���X7ulp k�m�%S�tSC��3��T�s���sI ��1����}��^n� @ޚK�y	�� �����:��؁4C�24,�-`�1�� �а~Pm��\?qǔ,�5�Ήd��y��7K1��?D�75�(��R*��G�}�v|��~���j?G�
܉� *�����$%C��CWt�ȶM��:@7����_8Q{v W	 j(��;����.��I�Q�I.�=�ƐC�'h6@5�L ٶ���DT/�֡�x�hxL[�W	eu}���P#}��D� �҆w�nC�+�N��A�p�߁#!���W�AOl�P�Yf(_dH�נ.x�
s��!ay�A�<��B=w	?+�Q��5�p�3�����w_���w��?����@W�$�v�]&�DG}l�.ʋ�G}��5pl[�2����h�/pB*��;��������:�a����OGlY(M���b��Jy.:�j������s��s����u���%	U���#�r�$�<{�$K���.�8|A���;�D�����j�-FP�N$�E�R�!�������F�d�a x҃$�k�aY3�W�Ap����T�§H<���Ej#vC�C���Q/q-Mo.�i�0�	��࡯�7���R7U�_:��k�.j��{x�Q��\�Sܐ?V�/�1���Q���4��FE`�;ƴ\0�\w���E+6�:�r'�ҝ�.]B�2�0�u.ˏ���
!:bڕP*�\_�T^�Cw0����Ɓp�.A*�Dڍ���U�[�F�����,�a������ԩ�繏ӥ��;��V )
��[4K�h�-�����Q��'�������]K�tCM���E�_��I&�<������0��A����A�"
�\%�{d8Y�
�.�B�x�亥���A��+��ba[c٫B$9��YD� �\X���\ް�H<�ׅ�O����9
�4��a%p%vW�L�0I,��.���v�r�`���_EÂ{4�N��|�/���P�-a��k�T�fS���������F�FXtsȞ��éE�K��'���jH("�Q���\[(!k�L0Afh.u�2�C�gـw[j�ī$t��^v�L�y�#��b��s�Ş��������7�Y�|�T��T�?V�DQ�4����$9��((�iH�Ǚ�XQ�8���$Q2���Q�<�ǹ��0Y(Q�֙A�a��
n��d���B���z	�	E�����v5��nj �on����y����X�r��IK�,�L�dUIMQ�QH)'IR&�� Kf3YHK����hԓ�dX��2D.d7x�]��B�-荥exs��]�_�V���[[���xh߆v�>)F�`�sM|�����hl���Զ�΋m$�E�.���m�Q��}�z�B��^�V�t�:�Ϸ�N�L�����)wjb���_a	y-�~��X/Y/7JવN����,t�j�|���
�p����o�3�ު�}	���Mj�Br'I�V�r�<9���c����V����#'����;��b�鮝l�`=�yl)���G��9��ԧ=�J����~yߟ����MޅF[�B^,ב�+��'��J\�.4�9C�ȋ|����_���f�\�^y���L&�8Β\Jv���ȶJ8��<��E�����h����#��n��PA����Ш��ۺ�4ڕj��F�n����BwTGKm��c&�r܆g�+��,�� ���N����<��x�#^!7W�����=���6EW�R��|��e�wUЇu��y�\D��\ݼK�_P��� ���/)��]��ԟ��w8��y�O��'��1��Jp+��4U�Y����L��E"��h#�g�(���f��)�<q,�B����m�]EE�.��$��$t�Prq������ط�.�l���Bp3�L~��W��R)����H�I�p��F�o���>�GR�ͤ,9�چ��Kb&��hۖ�;Xغ��06��$�vr��<t��W	���y6$��_��"��c�E[��h���6^�D �r[�:A`������ ���O�}�A|�������v�����,|��l;�B���裦>�s8k�E���>(�T췳�0�t��`7�.��y��p�U�M�qq}m8���F��xvp!��F^���H&�����4�f�|���E
q��lC5\�q��*<�|<5���_]�s|��s`��+����-��t��i��%���K�[��q���`?����������П�)��T��c�?� �f"����{��C%�5@6�������e�XqN��W�;c�����7�+������#Y�T�����=�����W�^q�2�ke�Y��A�Bm �U�~DK�oK2�b}&����PK"qN��a��fn����ņ��ɟ��B�����3�ߩ�we�iA�ݿb�EJ[��S��Ԧj_�JQ�������pD���3��0��5��ޝ��sڏh�8k���P{��
\�8����Y��֩�nZ6^f^�S�$7�,K��Cj�!��M�rrje���l��s�qɝ�qD�=�ޘ�}FVFD��N�ޗ���,��x
��I�5Ό�f-�R} SCh$��%��zlY�ggp��5<���$&�4H��|6�V���gD<�T������.��E�q��eb����Q����ҟ�j蕡8�L"����*��s�vd����R	�"3���Rj��/0d��{˦�<S{&�"��1]�V<�Kک�&���+�o�r�����-xǵmkm�gfY�+s�r�t��}_��◝����8^�m���v��]��=9�����+]��������z}�����]�|Q]�^��G��~��"�+44�0Fe�)d��z����\j�@�����t4�C�2�F��Bc�Ӡ ��ć:�qMo
]K��0��}C��h�����g�D5��5����w�e=@�ɳnYoH�WE	M�]95Kˁ��?�#sg����R��v�x��ײ;*�s��ZN��+���}�G�_���:}�s�f�+�ŷ�_"�������/C;@K�)_�1�&��.��
�V� i .X9��Z9(:����l�b���_��:Lj.�����.�>WL��#���cDsk+�rZ�~"�O��:q�xq{,c�F���b�9��,��4ȶ������d0��`0��`0���k����� 0 