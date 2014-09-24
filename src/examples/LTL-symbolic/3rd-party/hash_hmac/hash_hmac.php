<?php
/*
 * PBKDF2 key derivation function as defined by RSA's PKCS #5: https://www.ietf.org/rfc/rfc2898.txt
 * $algorithm - The hash algorithm to use. Recommended: SHA256
 * $password - The password.
 * $salt - A salt that is unique to the password.
 * $count - Iteration count. Higher is better, but slower. Recommended: At least 1024.
 * $key_length - The length of the derived key in bytes.
 * $raw_output - If true, the key is returned in raw binary format. Hex encoded otherwise.
 * Returns: A $key_length-byte key derived from the password and salt.
 *
 * Test vectors can be found here: https://www.ietf.org/rfc/rfc6070.txt
 *
 * This implementation of PBKDF2 was originally created by defuse.ca
 * With improvements by variations-of-shadow.com
 */

/* 
   HOW TO RUN THIS EXAMPLE
   -----------------------
   Compile: kompile php.k --backend symbolic --symbolic-rules step --transition step
   
   Property 1: 
	krun examples/LTL-symbolic/3rd-party/hash_hmac/hash_hmac.php --parser='java -jar parser/parser.jar' -cPC='true' -cIN='ListItem(#symString(x)) ListItem(#symString(x))' --ltlmc='<>Ltl(hasType(gv(variable("result")),string))'
	
   Property 2:
	krun examples/LTL-symbolic/3rd-party/hash_hmac/hash_hmac.php --parser='java -jar parser/parser.jar' -cPC='true' -cIN='ListItem(#symString(x)) ListItem(#symString(x))' --ltlmc='<>Ltl(eqTo(gv(variable("key_len")),len(gv(variable("result")))))'
	
   Property 3:
	krun examples/LTL-symbolic/3rd-party/hash_hmac/hash_hmac.php --parser='java -jar parser/parser.jar' -cPC='true' -cIN='ListItem(#symString(x)) ListItem(#symString(x))' --ltlmc='[]Ltl((inFun("pbkdf2") /\Ltl (~Ltl inFun("top")) /\Ltl (<>Ltl inFun("top"))) ->Ltl (<>Ltl (geq(len(fv("pbkdf2",variable("output"))), fv("pbkdf2",variable("key_length")))) ULtl inFun("top")))'
*/


function pbkdf2($algorithm, $password, $salt, $count, $key_length, $raw_output = false)
{
    $algorithm = strtolower($algorithm);
    if(!in_array($algorithm, hash_algos(), true))
        die('PBKDF2 ERROR: Invalid hash algorithm.');
    if($count <= 0 || $key_length <= 0)
        die('PBKDF2 ERROR: Invalid parameters.');

    $hash_length = strlen(hash($algorithm, "", true));
    $block_count = ceil($key_length / (float) $hash_length);

	echo "key len: $key_length\n";
	echo "hash len: $hash_length\n";
	echo "block count: $block_count\n";
	
    $output = ""; //"";
    for($i = 1; $i <= $block_count; $i++) {
        // $i encoded as 4 bytes, big endian.
        $last = $salt . pack("N", $i);
        // first iteration
        $last = $xorsum = hash_hmac($algorithm, $last, $password, true);
        // perform the other $count - 1 iterations
        for ($j = 1; $j < $count; $j++) {
            $xorsum ^= ($last = hash_hmac($algorithm, $last, $password, true));
        }
        $output .= $xorsum;
    }

    if($raw_output)
        return substr($output, 0, $key_length);
    else
        return bin2hex(substr($output, 0, $key_length));
}

$algo = "sha1";
$pass = user_input (); // symbolic input
$salt = user_input (); // symbolic input
$count = 1;
$key_len = 16;
$result = pbkdf2($algo, $pass, $salt, $count, $key_len);
label("after-call");


function strtolower($s) 
{
	return $s;
}

function in_array($x, $array) 
{
	foreach ($array as $elem)
	{
		if ($x == $elem)
			return true;
	}
	return false;
}

function hash_algos()
{	
	$x = array(
		"md2",
		"md4",
		"md5",
		"sha1",
		"sha224",
		"sha256",
		"sha384",
		"sha512",
		"ripemd128",
		"ripemd160",
		"ripemd256",
		"ripemd320",
		"whirlpool",
		"tiger128,3",
		"tiger160,3",
		"tiger192,3",
		"tiger128,4",
		"tiger160,4",
		"tiger192,4",
		"snefru",
		"snefru256",
		"gost",
		"adler32",
		"crc32",
		"crc32b",
		"salsa10",
		"salsa20",
		"haval128,3",
		"haval160,3",
		"haval192,3",
		"haval224,3",
		"haval256,3",
		"haval128,4",
		"haval160,4",
		"haval192,4",
		"haval224,4",
		"haval256,4",
		"haval128,5",
		"haval160,5",
		"haval192,5",
		"haval224,5",
		"haval256,5");
	return $x;
}


function hash_algos_len()
{
	$x = array(
		"md2" => 32,
		"md4" => 32,
		"md5" => 32,
		"sha1" => 40,
		"sha224" => 56,
		"sha256" => 64,
		"sha384" => 96,
		"sha512" => 128,
		"ripemd128" => 32,
		"ripemd160" => 40,
		"ripemd256" => 64,
		"ripemd320" => 80,
		"whirlpool" => 128,
		"tiger128,3" => 32,
		"tiger160,3" => 40,
		"tiger192,3" => 48,
		"tiger128,4" => 32,
		"tiger160,4" => 40,
		"tiger192,4" => 48,
		"snefru" => 64,
		"snefru256" => 64,
		"gost" => 64,
		"adler32" => 8,
		"crc32" => 8,
		"crc32b" => 8,
		"salsa10" => 128,
		"salsa20" => 128,
		"haval128,3" => 32,
		"haval160,3" => 40,
		"haval192,3" => 48,
		"haval224,3" => 56,
		"haval256,3" => 64,
		"haval128,4" => 32,
		"haval160,4" => 40,
		"haval192,4" => 48,
		"haval224,4" => 56,
		"haval256,4" => 64,
		"haval128,5" => 32,
		"haval160,5" => 40,
		"haval192,5" => 48,
		"haval224,5" => 56,
		"haval256,5" => 64);	
	return $x;
}

function ceil ($x) 
{
	$x_int = (int) $x;
	
	if ($x === 0)
		return 0;
	if ($x == $x_int)
		return $x_int;
	else
		return $x_int + 1;
	
	return 123;
}

function hash($algo, $pass, $raw = false)
{
	$algos_len = hash_algos_len();
	$exp_len = $algos_len[$algo];
	$out = "";
	for ($i = 0; $i < $exp_len; $i++)
	{
		$out .= "*";
	}
	return $out;
}

function hash_hmac($algo, $salt, $pass, $raw = false)
{
	$result = hash($algo, $pass, $raw);
	return $result;
}

function bin2hex($x)
{
	return $x;
}

function pack($format, $x)
{
	return $x;
}
?>