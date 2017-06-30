ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.9.0
docker tag hyperledger/composer-playground:0.9.0 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

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
� ,.VY �=Mo�Hv==��7�� 	�T�n���[I�����hYm�[��n�z(�$ѦH��$�/rrH�=$���\����X�c.�a��S��`��H�ԇ-�v˽�z@���WU�>ޫW�^U��r�b6-Ӂ!K��u�lj����0!��F�������6�r|����a�(�? ��-�W�x��r[s�ƛ�{
mh;�i��en��h�5:k�?&�5����>2�&\�ǒH�)�QX�kA[�jڑ^|`HT˴]���X^aV�5��2	�F[�M�	����g��T:J�s���Ώ �]� Z�5���I�0��Jl���^tC��U[S���0��p�y�@���[���}���,\Fܼl �A��6fFӹ�Ϲ͎F���]�&X��ل���5%�PBA�\kB�墔Q��5m�hT��7Cq`�	H���c*궥�E"~�0<���È��8�3�Hҋ���#�(�ɽ����j:V&�q�v�͖��<��.)o���(W�a�c#Yz}}�z#DXp�V��i:�Ni;и8&l�z�::JH.��8i�<�S�uU�� k�PE%k�>#Ou�����򕝲��P��A>�}5Y��ݎi���KO��3چ��DΠ�;�q������������ȝ��'�x��j��Л�1ϡ�?Ƣ?��sJ��G>���ʶjvo�
;�ۖA�����Y���g�<������7x�U�����4(�l�
���@Q�U��(D��by��)%�7��<���_����ȑn�h�G��($�0��1���W�g���,���1�o��	Z·�Ӹ�2��'v���ey���s\�'��X�]��< ���+���@V^�o$�(L�	G��a��-h�2	s�kܲ.g�`���?@ʹ�j�u��f�:.�Z6^{�X�֖]L�k� 	�[nô��*��)�pH�D4�0�y'�����"�N�r�4d���֘t��[�J^R��+jA�f-` �5�"�]Ct��Pu�LH֭��-����ca�8�g�y��^B�Դ�́��-MWC��4�6!���t�B��c��7\#8 1�e^��Sc��1I����%U84T?׼(6���(��~��PL/MW��O],��Y����"��U'������B���o.���� ky��2�Q��'��amæن(�e�Q��p�~"�5��ϨwU`ן<U��B��(��`m��"�u@���K���$T&��Py8o;Z���w �l�h�:��y%:I�TMC�s����ҹ+K/�J����X�	H� T��^�V��7�l5�K� ���跘�BڬpI���9����L���:�5Lu�h/�4�{|�?0�=5L#�7��q��ͦ�h?W����(2�K%��>:7}3��ű�U+T{������-�%�0���>�n5��C��u��Cف��:T\�ihJ�D����>���d���ilH��A�osF?������m~o~�O/ޮ.�	��۩�xFX�% U�'/_^"��G����hBg��CGV(�4�br�a���ѝ�~0�n���b�7X�>n���}yGeL�o��?����<)ui~�43��@L3H�Ӈ�<��٦NSX�M�r�S�Z��s@Ri>�ݥR����	U�̔���R�PY��&�'c��}������ _,c���:G(e�G�R���瞟]\�̾�;� 4��/��� ��a�%0�`�wС�����D9����(D,^���[����Q%���;���@G;˃�D��:�F�0�z��:`�І��?{ÄV�>B���_�7o�����<�!x���#D����5�Cj��V�
m|�5������iq�L��p� �͊~t�q�-B�B�"������\�[���q��f��8&������ㆱ�?�v�r8���,3���ĉ��w����j}��	4u���PȲaM;�ye�'П�R��0�����ۗ1��g����y����+&,�bL��~��?�,������s��I���?\��-�?s���_	��M��m�жM��l�p��fS6T'L�x�����ol Bٖ-��ꑼGw$�m
�8]ǅM���]��yF�OY�F�Ӎގ1*s�4� L�>REzEk0�Pt((�����g��������[_���j�w
��� d���#��1�˳j!?+'�K�E���� B������n�����[��<�C����1����=\��X]&�c��!�s.��`���c�>�`T�P�يp$�BL�3�T���]��Q{������m��.:���_��\���{�s5�S�,0=��$1���Mu�2&��3?l�gyvq��\��c�c�8�C�e���P�/��	���ͷ'�DG��/�������!�\y�r�bp�u�J�y�t�f$�Rd|�-���YɿD!��(�HM���ј&�.NC���U;�ws�"��q�����C����!�}l����F{�CW�<y���J㛿�F��nv�dͭhމ�(�?��m�#YIQjӞ�ypn鏣� k��Bh���G�UG��^�����_�a�ϰ�=m�?6&����8[��y�/�춂�s��?.�;�B`K*"���K��
q$s�N���	�T.�&��⑈�I91�-���1O ���\O���bȕSˁ�H�`�C�`H�H��q�@2_��
�T:S��T.�;�|J�H�
!7���E5I�\e�ehgH
Gڲ�[��Ga�	&�Χә\�h[ڕ��SRb'=Rp&��Zd$���9�P�0a�ŝ2�2�vy����)e*��xB)���j�mWGCU�B?KRe=�ٷ���q˪V��'�j��4@Hˎ��� `�*��%�^n�z�	���뢵q��ʹw���n�4����?bÅ��|��?�7z?�+H�hYW�3��\B*��qz@v��z��ٻ� LuXe�

�+� O1����K|�x����2Y�f�b�'��5��t����hZ�r�;*x�����<`���ͥp��?��P�G�`!�����M�?HA�{h����Ia�]�k�@�Ӊ\Ƴ���S��oy�y��^���@�Q��:p= B����<V�{.�aZ��K'����/,��|����8�`+@Ͻƻ��
]yR*E�A�ٓ�קߠ<��4�ꘄ������K!&������X����_�OV�-UM��pA�O���]5�N8��1xM���9<i�������
�bq~���ܖ�����zxC3�<0f��V�3���"@`_�z����n���@~�b�8?'��(��{,x�ř|���df��/７R�>����?��?�2��ʰoÕ/�\�LzGd�)c]#�IƼ�2�x/$X���%ƽ�sݻ5W�Vx��xU�~w�6�ʃnS���p�������ƣ��?�3��'�f*c���2���ܰ���4MS��� C����7x�Ow�^�)JSQX��m�<���_�r�;��]�N�Xh�x;˔!�p(���v�:^�e���v�*Z�B�U T�U.&עPV����FEbUkBuu�c '�b+,�)5�ʪ\EEh���фbl!��V��j5M!w��!	)�Ɂ�T�d62I�"��C#��$���IQM��N&!�3��nQ�l��
����Uk�L�\�J�맍��|�XL�ǉN��t�dq?�[,��Ϋݝs��EE�쎔Ld��܆#���&o�W��l�H�g�����H�Cc�?�_玫��A6�x��b5��Ȗy�7\%}�o7s�j�G<�p�`�p�Ü��E&{�9���\�@Fa]/L�e7�3T�s�U���M��Q߭dKَ��,#u���ޙu�\�V�z#[��l�$nS강��X��(��f�R�\;[Z�lz�S��A� �ZՓj�l����c;��Nk�[u�'���yhl���c&)�3�wJ,*�b]�R�\��q�ȝVU=]�t^�7���1����<L=�}�<46wcI�Nl;�ZG��qA�9m���Ύ=ȗϓ�/(���f[�sZ6-vRuDk�)bq3�Q�����D����X�fE3�L:i����z>�;$N�H�H��̊bg���:4P>ǉd��1ź�q�ܞsz�²��_sՕ����ٴ�Z��Eڼ|RΛM���{�>4P�%4S���)��zU:�2���~1���:�V�魴����'��Ծ��*�U�a��_94vJł�Dگ���n1�g�mq��|j����9���R.5�5苋���Sx?��#?�6���f�/����Ot��������
0��������o��{ޤ��S���w۹;�_t��/`>�?A�g��0��GYn���| �J�]4�-i��>�����X�D��$���r6��~#����H��4ӑ��\,�����=XIȱ���;~D�f}���]>Vef_��^�&���t%1��b>ƾr��g���A$�P3�%G4#u�yD���d���LّNՒ��N�?W�m۪�*�n�T6�~;�y1�Xl����hF+v߭����1��F�~1���m�oU��x�a��ܸ�a������v&��}��M�1���AffsLq}=8�Sv߭�Á�����vϦ,c��Y~���-��P���zG�}���}������C��~�Sv*�ZSy^�1FY�q.*ê��\\�
'Dkq6�F���T���TFY�QE�W���%@���/��?d������������/6��ӗ�{�o��үR�,t)����hY:6�k�����O���:�-��?X��K����ᘶ���K��D}Q&���_��'K��`�g�}2��@	��ԏ�N�����������C��=[s�,���#�y? Ǖ ��:�|��0�K!��l�����߿����_���/�?OO~CW������>��)�۲a���?3����	�/��a�o>���e>�?����e�r�KI���A������zH�g`F���zO�$�#�E�����?(�$,K�]���r"�b�Z�� '���x.>�Ň������0fF�k3�R�U���� E!�E؂M/�؝-?��H��*'�U>��A���(_������k�,s�(��ʩ�Z��*ȱ�
�9A>rN@������������q[���ߵ\�W:��B�Q6�s"@���E��g�JbG��'�Lj8�㉂Y\A��$�X��&RT�7QEI\D�ʡ!�"�P����rH� �Y� >: �� A��@� q� �C�܃ � >9���R�TKwu���zTW�������[������~����2x';���[�"�U*ڦ�?u��zq���2[�V�%�c+�D����^��O��ي��VV-#%�O�.�N�����*�*�h�xk�X޲���<���ȏ�*�ȱV���ۿM�c%XdU�#��J�$�s�	��\����?������t�a{�Ñ:�3�r�9Yg.s�j�?<��O�l�xo���a;�
V�<����q�$�E ����=��[$J.~Cm�~��U�'�1rٍ���I��'޾Ʒ�^��/���p�_ؼ%I����F��K�u��Kr�9Y�d�BW��;Ü�홥�0k�0ş��J���H��}�&�n9��.��$�vu֯�?I����z~�t����B��k���/�^�w��d�]'������q�ɫ���حq%	�a<M�Ą�fg���F*�:=~pc��*��_�P����<��J�*�B<�����ǫ�o��e��\Y!v��!�"e��Tc1�%�t�Nju����G�������Y�<�'y�N�ɇ�����Gv{�6í�
����eӤ���d�<<��vx7��$��p���֯~�~1��50�Ǳ�}2�ی�E?��$l������/��2ǉĝ���d��u����FVr����8~&`��)�'�������r��2���_���[!����~��_���_I�����
�G��W��߇������:��i�7�ԿՁՁԁ�/����+���$V�Z�o�P���q�m�20��Q�eq��Y��i[�
�:�(e𬁡9�cG�@��@����Իu�Ͼ��_�~���O����o��_�_��K��F�
��J꟔��< ^;���������D����Է�9����;���6�����z;��R������rIn0���M�~�,��?�3H�sƅ�4�x��j�I��*u32�dw���hU�윔�9��Bw+���u�4i7�i�#��c�¨�1�� ���hHo�!ĔS���WX.7k��I����M*lɘ�#�����0E��Q#�0ř�#��#��3o�Yt�GE@��|�g �p�I~3���j]��BBE�*���G@�r��W���Ը!������I�=B���~����!�{��L4�����JXm^�i~ؖ��P��,��e�o2���#[���:�z�H9R�7	P�3�6O�Fb(�L�@�6�R
�$9��]^�]���r��۳`�b� ��+v�h^%L{�!�ce=����m�\b�S)��']�e���n%�֧N!�����DI�2Z��J>��Eچ�.��A��B�Җv�Ȏ�<��9(S���*Q�x�I��lR��|Ū��dUI�rUE�������9+	$��(*��3��&OdX�y�F��2�8g?�HE�؈�V��d'Zu�$R�\C���� m�݂�!)��l*Wsr�����2��N�2�e�iT�к�G�qvЍ!'=4ߑټ�EX����H{�G����D^H-
��e��U)Jc�yq>%Xj�@q R@�sr�d�
(P�A2���	T�<�|�w��p@�c��I�!�N�	��3t�+5IG�p���4�7�f���5��	7����8�sҝZ���aK�
�	z�ܠ�F� �$�1x��a��N��}F�r�)!r�~4�;��V�c���|�E*]�Du����h3+��Rz�����dT�h��>O5�|j�������:�d�B�=A�=��F�xApQ%�A��!,���^(,�Q�d����y����0h��\=$�p_ɰ��!ᅰ��v���!:�J05⫝̸���}��F����Jgj�C�t.��>�R_ߤ��i%p�B�u<�M�x��V� 7-�nZ�ܴ��ip���;�,��e�@"�W��~�ڊ~:�����/��z'u�z%��g>w�Z�y�2�O΀O6��~)f���	��6���&�{�׻��Ny�?�8ݓ���ߺ�4�?�����ԟ�;=x��.���U-����DG���^�3�N���u����f���1�7���I_S�^�K�r}&�aVo�T��ײc��Q�0��I�XE:�-O�H͇me2u��9 �WJ�Ҙ�jCD��m������-[�!��n�\.�Z���xh�����a���{!6�Yҥ���Y� m����Um��l!r�ltGJ�^h����):�G:]��pM���y���C�	%��f����\�n�0p��g�bI�)L�}ɪ	u2� r��[bv�b�ǥ��`��*v�T*,ύ��&u2F2N�m�l<y��jE�DՎ�2`�͈l@f�`�1A�.7�n^�%$��A37wM	b�m/T{�y�X��L�H�Qx Mi��r�(�1*'4�F3?f#s���"K͌k�P33~Xm�Q_T��4��!�'f�C`���t�%X@�XM�қJ~�T|Y�R��B�����4]�*�NṩX�IU,�*٢bA�-z�uG'�c\P�{�1K��z����g9≎��tr�žE��ө�|  �y�������Z��R� ��g��J��$.��*�"U�Q˥���,��P�3��ny�Zq�R>V�4rn=Jb�:˵�F�T�V8m��*����:� k�Ư?�
�}���M��B*��3V�]�N�\��()ޒdt���~g@t��^��t��Z0 b����4y,IN���N�le
���{*:��>V�\����TD�F�9YM�(��R�&�g[����ۣ���'56��$���4���tXz��$�Pd=Ɔw��p���[tD�^�hsH�UD�N����	�O��,`Z�D����y	c��$��!�Xٙe���fʸQ�FK� Y�)F��I���rq�6wzT�����xP�$��Vt+z��� ��igL>�4^�+�%F��%��xI�[��(*���j�z@4y� [c} 9����3�Od#���r�>խ��4� R����d�n�z*���68��Ks�h��~惖ջ.S��G��
y�9WQB~��	����� �����	��$(q��6^�8p�7�~�adI�M�r7]k:P���Z�SԈw�]M��&0o��Al�U33(�]!�T6�|��2V��QmV1���d@_�Th���w����}��>��ϱ�V���Ѫ�X�j�{��=����׮��B",Fu�U�Ӛ��.�h4d�	�M�i�;�}���8�8��?g^Q�S{DХڢ<��̃Y6?�J���h�(�vP���N�R�*�D��Z�j�����w[`	j̔A �|��5�r� jޏ�rw�!�Y��בTXGR�#c���BW�y�X�X�. �q����^��#v���}B+ֽj�$V�hd�����.�] }ui.�#��H���q��R�0�������GM�tI�&�W�q�Z1"g���T�9Б<R#�����
�2��(��/��:\�2��z}=��~�q���'!'!�k�s��e�VM�
�#w��<L3�
p/���$TfC+�f��������%��R��ёݹ�z+����'�|~��O�]����lڝ����?�`P�$V��{��ιj�u���y�\5���p�{�������$Wm�\sY�|��N��}��Xw܁C�?f��S�$�{v�?���6��W'����X�ǣw𓘾p�N o��4͑�V����!��j��H��5�d��-^Tz��/�e׺Ǔ���`pv���6��Y6��O<�(� �~�o����o�M=���(���6�N������о��m��_��Z�]�=m�ۘ������t������e�=����_P����������s���M�����6h����D����{��=������!��d���Aw�;r_�7u������K�?Ùx���t���Vh�G�ny��(��>
�^�χ��o��f���mЎ�?��w�wJ{��Ŷ���g����;��{�Gt�A7�����o��� v]�������%�Dt'�?xc���{��6h��_���}`����_l��N����x���Aw��3�� ϙ�����M�����AW���EV���/��a�By��͸!m�h�G�Q�_���-Pбo�X����e.>p��O�msP���Ix���y�����ԧ�U�!���Q��举��]��WeR��v$aT�ҍ����$�~78����I�� gڣ���h���`��N�J��A!;�A.����;>ʦC�J�ŭ�D�`�������c,;�v��CT�S5Q,�7�B��z���#��\Diͯ1N�(��R�����W��s�����k�˺��z�>{���a�aYlo������Z�p쏬���#���/��w��3{�GtW��2̜M@�(�!&ff�,nY:�C,�u[og� `ԶsmH��l.�c�4۰I<���~��.�?�Û�?���o�����TTcO�>�j��?W��N겝f���vE'=n�js)�
]� ���+b�f�E7z�ʜ�#rHw$2y���kZ�y8�Ge�>��TpN�2��%GȆ4�?{g֤��E�w~E��2� ���
��K������[k����[SWrNT�/����2R�\��>�ȋ@�M9�]n�h0*gkw�����Ը����?���Cc`�i���3px�S,������Fx{�O"0w������Gr��� ��'��`���X�Ŗ���G����������o����o������꿈��(g8>��(���"��.��<I��J���":f�$:��8���e�,����o��U�����F���a!�;�D�b�vH�ۜG�if~�C?�][���?�����F�g�.��	��޺���򰤫b����l�:s�x�I���ywն����E�
�k�͗{A��{���O�������S�� �-M������p�O#`��<俢����o\��G��4�b��?4B��1�Xє��h�7�A��	 ��!��ў�����_#4S�A�7������O����ߍЬ�?�����?���C�w#|��+�c�����U߿ؚ?�zk7�6e�����X�Շ�k��i�ۮ��Z�a�z:��k�|7�Z�֟�������]���~Ǽ�1�դ�I�e�^�S����r��%g���)�%�p׾Tû�([��0��e�Ga���f�>����Ѻ��y�u���N��k*�/�mߔ����ݕ�-�M�%Ժ]�v�lʞM�ֶ�#��;��e�Q�T>|H�,��T"�����̾�Oz�ݽ2i�*�>t�3+;F,��P�
^�D��3�D�X�����%co�$�7#�0������uϱd�PyA�t�}e_��p�*�P�!��������P�5 ��������A��F�?�8�C��?t�q�O�E���w��r���;��>9;�v��*iۖw�S^^w�@��mO�S�G�����&��bc(��X�Q��uÝ�ל��Ə��dkmzU�6tS�'9a���[��lד����.�˵����XY�c�n�:g}s�G;ɭD�M���n�jÍ������-\n�+��2���1֗�n��W�������%�ˎ<���{����!���p��������p�8�M�?� �����?���?���v����?�����S�����'�&�����#��4�b���o���߽�M=�~�c5�������b��_ �o�������G����_�����A4��?�����_#�������������������B�Y��@&����߷������?����A����}�X�����������������Y����[�������7f�E֙M��nm���@��������M����{�h�]�k������i�Y/kO���Ɖ}?e��6;�����ː��Ѡ�}>�������P9~26gw�]��ˀ�ꢲ�j��)��$+�B���������_U?8�/������Y6;�N|�<[�C�������1X��)KI��)\���7n���xZ~�����3�,�YT=�Ri|�{�/�i�隴Z�����šPm�?'\r����aq�������^�-}"�SΚv��,�F�<m�����E�G�8�����	���Zw��?"������g^���o\�?c�\�%2�D)f2�!iĥ� ���1Ee$+2�@�Ȳi,J4�r�$Q��P�������������������?�����������_��]��fE'������Z^�8rXpƶC�7�$���ک�)tŨ5�-֓��\��#˶�9VV��g��ަB�n����b�����	/tg�醜{Si	�z�z�W��9q҅��aM�6��:e��pOo
��8<�!�M=���F?�������Ё��C�2�?� ����C�2���A�?�����������P�!�� �1���w����C�20�0�� �����?�����!��?�� ���������@6�����18�����������F����?���Y|��mj?�B#_p���7v7��L�?��ᛉ��8?�!�/��nM^F7�4���,��h:��]?�&��٭.D�&>v©����m��Ƿ���R�K9�H�x�^�vXw�_�i55}vN���"ތʄ�M[�{���*3e�Se�R�Arn<6��:��SHKG����:���*����r7̉j�eM=����RF�8]�y]N���lY�Yw��-/�=��h�غ�����v(�{���*\�dfc������V�͙�FKS�ku~�ImrB<�"?��?t6}`Y��x�J�-�{��)���}�	tLY��:T��w)��U�w�|���#�����ד"�c�v�b�;��'�n��h�w��M%�SWI�k����<����8tO����t�T�}ݥg��j�\K�>.I��W�)��֤$��s\�y�.E�\9YR��~��gg�F
���b�,�?��@���?��}�8�?����H�Ny�J�,�c��r&�x)�"�b�$�Y�dҜ�%�&3��Y���<ɓ�J�L�������t������l�D�9u}� ���$6C�H#2Ldz���n��O�֘��oity��Y[U�~RF��V��.���K�i0�;��O�D*�Vr>��(K��:��m��f���}�u��%�|/o��O�-��'�?����k�?����6����?.��}\i��������&�A�!�M���o��/�C )������򿐁X�!�1�������{���?���o>���
!��є����/���_����\�{����&�+�(��@E2�����ߧ�0������o{xK�y$νӑf�C-ȵ���Z�lV3'/<�C"�g�ji{Y8S���U���S�6��t]v�} ݖ�MjnT��5k������<��io�� �jk��}�Cɭ����fpI��c��?��*u�ǉX�)���~?�7�Tew��X�LW�Rs��n����5Q#�Qd���޹�t�c��4R���L�Q����3�����m��_�@\�A�b��������/d`��`������������[�߾�-�k�0��t�M�2�;�,�$���=�_O����6������Rw�4PH�,���tܫIUB<�y����iV�{T:�!L��Ӌi�u�����Xך��!m�c�_5Ϸ��i"�Kѧ�;��V��k���~����`VPSٿ��%�^�j�H�s�WOVM^*t���F�]�-��n��e�z�2Ъ��0]���ڎO��<+��j�˔����ȮWjje/�KlM���V0���m��wi`Q�A�2���������B�!�����������Y�����&���>�S��>��3͗�1�R�:�C�7���/�����������:)���,>�U�ߝ�T�V����վt�	Kmv�|���l��9�=�<&\*s��T�9ūǽ�{������e�Zr5)��i]�N����'����������ǹ�/������Y6;�N<�K��Vfǐ��ȳ���e��n��L<S	k�.�b�m�LN�>�u�����#�s���N���݉��E�ͥ�E��2;�=����]Όr6=��2/iݟq���Y���to��}�:���[���Kv�RK�]�9U����.��� ���?��B���]������\�_���SFbH��*SA�r��#�d$2#3��bR���K4Q<�=r�H:������������_��+���p�Du�a�Y�`pu|o\J�y���nlN��ր���e�wwjMf
#�����{=�5����t"� ���:ݥ�չ��q0��l'ɗ@��B�^����]�����d$���f�$�}/8<�)�~���w#���'�;|i�����#y�M����S0����?��bKS�������	`��a��a��7��X�M9��3)ΥLHEI��4礔���hNs�MHNL��JH���c2M�Ϡ��f���_��)��i�_���f�M�\��J����F̨�Џ��d[�<���[d{s��}>���5�N�~;l�Vk��c��=�抖@��N2�E��Ӎ�5��s�4C����Xf]M����luuVT��z��ޅ������b��?$�5�����*a [���?��g���F�B�y�EE3�1߸���Z�i����h���b���)����o��m����o����o������B�����+���w�������hV��������7ˁ�o����o����o���0���f�?��������A���t4�������[���������?���������7E�>��4q���s��������4�����᱀����O1��/��7b�������G������o|�VQД������ ����������CP���`Ā�������*0�0�� �����?�����a���?�������B���?d`��������o��!��!���q������Uv���C����w����3ԋ�������s�$2i��Y�qt$�R,f�\�Id�dL�2	�$�@&� qq�p$�	�������z����78�?�S��/��o�/����{w��/C?��'�5�k+͊N�ѣ7`Ys)��+?�{W֦&�e����\��1^���
(7�08!(�o��=�JN���u�'��Rj�X��{�-o�����ChxR7����|�����jE���?,V�Yv�����ϜM�~ʖF��#N�8c����R��z;��Xs+����f�����x��e�b|2F��a�"��Ww���~�;�.��A�G{h��?������Ρ����C'������������[����������t�����0�������@����@�G� ��s�N�?��h�`�[�����������A��-�?���2��������?ZCg�������� �;��0�������o�?y���Py���h��j�����+���:�7�?��^e�z�-�}�>���oH��	��|a�[I�ܾ�`�B�Cg:�&�2�]�C��ML�8��o,M�f��������+�h�j�y{�6��}9hJBÕm�؃5��@��rZ��&s)�Ǧ��G�K�yJ<�F瓖j�j��٥�i�i��l�0�������� ��5���@�G� ��s�.�?��h]�� �S~����Cq*F�8�,��=����~�G|��{Bxh�GT�}�Q���k�������;�?�ٖW�������ݱL�nq����gŊ�l
�e����K����<[�	4��~y�a�T��a�!#���q7�-��;_�I���NI����(B?a,ƘV�`,ƾkM�ɩ��ſ�����h�=|����Ch��	�������_��(��F�������'1��M��#�{��A�����#Pa���'��O�8���>�����1J0AD2}	#���~k�����+�������D���x�&Y�s*\f2�|��m8�
Ǯ�ݐ�^���3�^n����`9�-p}�`i�ϡ��:�_R��p(���H�`�.�JD�'��,|���N�5~Q���t��>�.��Q�n���6�&��suM����E�����o#x��Kn�_����7�
��<�;(f��#�(����w��|�������*������tϗ�޶|A������z��o������ʍ^[֔�'��;��$x�q_��T���P7�����by�^���u��:�<�Ū<�9��?5��8nT��#�~ϲ���v8N�����kf��1�c�5{k
�����/�G��P��G��-੦Ss߻L��?%KS%��o�
�������`
�$g:s1�&*E8�����tV��X������2�ކ�Bj�6d��'���#���R�Wdr[`���T���O������p�G8�k������A���] ���6������0�?�'B�AS��������&��_#x��gx;�	&o��`��2'1�GB��"����O=����m-��3�ם������#dQ����'�<�2L��7"k�S����(˪myPcM˄�e�Lك©��|J㵽�܅ǈ}�m
×Y,s2.y�3�
����ǜ������m����z��~�Q��*/��IQ�.?�N�
�\��T��X��}�f��<��c]#�}��<>?秃&$`UQ�Gb�A�6�S^���9��v�Les���^����q1cS���0")��S�IX��Ɛb$�����͎���6��;��}���������������ϭ��������&��O�o�}�U	����G����	���9��������{ɝ�/����sC]_m��
��]��i�W�]����2�~J۝%��]�^��K���+��rm�<�e�Ȼ�Ǳ�|�C#��$�� ��YD����ʯ������O�r���z���sk�'���D-��
,Mq0�1��V���ʸ�6��l���:7�˳:��c �s��@�t5�)�o`҄J2=fCD�r̫AvT�c����k_�0��'WC<�G�A���3~�����Ay��/��t�*Ҁ�R��cҒdS��v��3��"�rbc�q��k��o����Y,(��%��φN�?���-�U��_���{���&p����{�S�n��t#�L�WI5,�pM��	Z�� ~d���E]��`~d���E��JJ�����T��5S�d*턁���zhﬖ�9��r�ė2{ƈ]g'�b�Y_�J6���VN�XVM^�yF���>U<����"�����=^&L����dR�{�0FT����7�i�=�8���PA�Z1���a�y�<K�˘3�
>*g�����ȏ�=�B"��g�%2�#�̝:&q(�n%�rۂS���]�2�@�5��@�w� ��`������_���?`��4��@�{��C��_�&�^�7�n�����A�f�����b���x݊�?Y�߶rC[]���
�?Sf����/
��\>�'=�al����p���?�h[ڎ}�v��mT.�m=��NV<(�P&�kq�p���:0oy��X@'1������f�et2��]���G�B���/u`�_/�4f����{�E����i6�j9Qr�ZnC��N��U�L�3��%�h���ﷲ�YB�'Iy?����Afx��m��;��{���7����~�@�߃�'� ��� �?��'���y�:����Gkh��[G���hx�C�M��w�1�7?���u�����iL��ЭK�Zq��Z6C�������),�YL7˵�ي�D�pCI��ݝch��?w���+�*+YRE{C����n��f5�;����o�����=�
���e���h�nlo۟�#i����V�,�4�q�ċ9Yw����^�H)��׺k�v<����<�g�����]�W�����&��e���ǎ�?|n��������,��
P����?��@��@��U��h�+	�_����Cy��m?K��&������3���w����o�����pG� ��o��1��?���7����� ��o��������:���(�"������]���������������I�v�u��n��	������_#h����o��n��������_@�5���Lp7 �����������7�����1p� :������	����7�L�����{p˜�	��~�����~���%�%ӌp�������:'��^�,ʔ�t�gT�iq���BdMy*P��eY�-j�i������){P8U"۟O�b��7"����ϳMa�2�eN�%�9�;{���\��-Ko�8�o�8�˪|�o���̎&EE��:U+�r�OVS��bE��՚qF�lb�u����fr�� `UQ�Gb�A�6�S^���9��v�Les���^����q1cS���0")��S�IX��Ɛb$�����͎���6���=tB�!�_��o#hK��ѹ�����v����]����?������Q�Db��P1��8�\*B��~4G}$0�j� "����_��~l?���8���?	�x����Ⱥ��/���ix��܏��9	���ـ�'r
Ӧ?G�K�^r%��^�� sʽ:ShӔr�ܙ��4�[���#o?J�\,CE��c�t3�:��Շ�c8���S�lx�95��cV���_�Q���jw�\)>��2'��>'�W[w���~�;�.��Q�����C����r(�vM�����P��&�	���{����1���_ �S ���m������Z��: ��o�����0�������4��?�����O# ��������v�?����_#hU�����������A���	t����o����0��& �@���O����� �ύ�U�B�Z���[�u����� ��!t��<
N�@'�����o���/������k��2�V�3g�V�N`���m�� �������o�����
��YY���6;×�g����A`�@�V���	'Mo�˦
sJ�~4�$}F�DFP�����dz���L�)T����.$䰫1}.��c����M�İӥ�RUbk!y��ӛe�X]`;�u%@���X���})��|��ׇ����/>7��Ց�Ͼ?�x����'�}�����C�4�6�� [�pA4\���2��uA�Ƙ&�DV�l�Ӫ�Ȧ�������J�	����B�gksH�W�"0$��w�^���O���N�?���-�U�B�Z���[�u��q�A���m�����8�� F��I1T��c��|�d|*����B������SLa!�x �W����t}���;��gS�}QY�vN��!�)��JkUy<�J����K��,8��x5.2Je����Ho]n���)��)M�C?��L�顎��ߤ6��/1ql,�N���U|8�O�G?��OI5xz�r�s��;��&�;��0��5������%��xJ�/�͗8ݗ՗h������n�n�/�j����ko�AeT}���x�7��޳�:�\�3���S��;t؝�Es��L�2cw��n�_~�ۏ~����/w��n�m���J�QBP�%�)���I@��m$�"��@�/>"�JA�۾���5sg3�P�s���S�էΩSuΩ��Pi�F=���C=�Ԭ���z}�w�[1U�E?a������e������S�'���N�c;�7b^��Wa�`Q�専WvV� �U����^B�q)~�άߋin�Ӳc/v[��3PB��0��y���k�>�-E"6rc		�,GU��]cI>?tt'6;�嘱�2
K���c����>���(�%H�@�D����H��_�)��Iθ�և�t���^x�$�W���u��ܰu�P[�쮎�8zo�.at5���U�{U���*Q�j��jx8��9�&Q�r���b�n\���u�}�;t�ֲ>܉y�>L�9��H�o`L]���;a��tM�n���l?��c-Y�WF��
��hң�Z�i�;u�Nw>�������> ŝv/ls$Kwޝ��:9ޭ1f���N��$�0���B�$��d�|��=���2�o�߾�������~h�Ҋ%^|	�u�EU=�P3zI*z[�P$�`I5�/#��j(j5�DK���T1�p��'#7.t�����3h~�7~�{?�����_����{z�<�����P��Lx^�R�	h��
�
	ezb�^�l���
���i����B�*,�� u�+��>w���ֹC�z��6���B�
=�u��WχyOՇV8��гЕ0��*!��uE;�����^gi0t��&��������>�ɷο�����~G�6���Ε�x��]���n8��wL��}�_���,���É#��O �l�.�t�����}��[�J�������7�|���ٱ?�ԾFAߓ�w%�f�[箞Ǌ�5+.�t
��Xڋ/aX�m�ሡ����fҘJ�PR��N%a����$�HaiMf��F�xRO!Hְv(��%��_��W������䛿�������p��G����wD��"�"�ɛ�����7��8A����k2��k۟~\�.�y����}� �;��8x;��W�RH�3Gy_���`��T���U�q��s"����3�̬5g�G��p�8)�w�2'�A�.�8�p��ԣ4{���l2 \���<�EY�3"�+z-������zk��Q�)2u��-_yʕ%$;�5k�Q[i����iq��,��j�;����_�S�NF:}��j�|�B�)x�C+��S}Y,if5��Y��~^���窉���d�%fHʀ��4>��b&����Jٯ��	�)��VD�9a�<��Dk�.Hc5��k�@_]�@O�y�9���ЬY$EY%���`(���v�Fk2���1X>Ƣ��n�7���؋�{�"�}�@�d��b���Ti��-*��������I>SJ|�����3T�2�E���	���Pz��6M�s`7�H�Iw@�&$^{��z�ɇHَ��g�R����1	b����������]�4��aΎ���m&X�hN�	����%D'1� ���L���>�E�V㔪Xy���B��E"Q�d�J�=�2�j����/�h��M�Ȥ$g��(�t����^2����E����FٲM�oُ�(pD3b
������mQ!�&������j���IP�G9A���^�s$��B�#�(�!ܽ���q&�1U ƹ�xv��f����ì?N�<�m7�F��˦�X�����F�<���6�N��|�|�L�\�\�Sn��jb�X��EZ����<&f9ːSD�]i2˚�V���!��,���j���s���J6�5��329��mv�-3x��t�,Y/����9X��Z�� �6�h�B�z��7zl�c�U��a5��^��A>�{*��)���$�ͳ�?��SW܌��x<1��]1Ŕ�\���2�	��,�䐭�4,�k-9�+�;S��(�|���P}��Ѿ�ܾ������N�
Zh�5:h�3?2b��.�s��Qt��?���p�q�G�a�`=��İ�� 6�Ǘ��8æ��MHuzZ8ȶ�F��B;�%˃���A��l}��D�VtzWnP /�(fH��� �@�;�4�I�Sw|[��d�"�)�@1��-�'�r8�d{�86���ZȤ\�X�^�n m|>�7p�V����'��*n�]�J`?����'
f��.;'s�\�ѬFZ�96���i�k�t��e�A�K$���@�kU/�����&晩�����ڸ2p�Ik��'�����|<)�	��G�����N�`)�K�υ+�k�t1�=�����h�7=^��W��χ�Y+pemA���&>�C�W�п=s�&��3�_�����v��菮d>|��ϏL�+�d�(vt1��f}�X�M?�꽘��2y?��A��[g��C:�&�ݦ� ��3��%H3���VKn��jz$�vbP/{̦��_� ��VP�=E�)�Vm�c��EV���^C<὘��9Q��X{W7�=̍�����bˆE���95�S�/'3���|8yg���w��> �y�M�/7G��O������P�Hy�w*c�`�6av�F�Ұ:�eB�=��yK呂�!l.�mѸ׏���%l3?��y��ID��g�)�H�/*�!�T�ǐ>�*��P���xi�J����x����0����5��
�c�9�J��]cDz#��%�>s�
�#��������#)����R컩b�.,ӻ��� E�O��i����HA֦�ט��t��z�tK��Uq���\�R/(A�&�)w�y^2��`Gks�,Pg�\�z�7�]I]���y��$y���j�ܰ�dQ0�EU�"�@�"'���8x�ZZ�nA�u�n�Rg����[����-����U���A��� {��b��[�߾���o܄��&�������!fs������'�K��P{��g�z��$k��@�By����&�h`������j��ٍl�0	��$0`�ɮDUv�x;��-�3����yj*dDM�sn���kj}T��av�r��c�:���`l��ʍ��ąG��P��O`ʨl�G8#����OyN<f7�C>	?�t�nR���xq6���n�a&��^���lQX��m�W�V�p�Y]%5K��ˏ�e��]VQdZϠ(;�z�
��M�%��| �l���Ri����96~��Z?��Z���k�O��j�=�x��=��C���W/6_�����ũ��䁕��ѭs�������u��z�}���!+�ˬ,�� >�g��u4��ŎDhkq���(FPw��/�<�
]O�n��>ѽD*#�#Xsz���޿�-������j�^��V_w�#�g����4�_�Jwvv�H4�:�>}��&^��'�����+���d�++=K[�8�VߊT7��Pw,�$z�"u��|w��m�Eݴ2R�
��X]�����QϮ�qpu�M꾯���6�~�ލ�N�3~E�-���o��6��l`��6���d����� � 