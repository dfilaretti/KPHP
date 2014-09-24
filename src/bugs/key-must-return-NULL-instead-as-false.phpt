--TEST--
bug 62901
--FILE--
<?php

class Test
{
	function run() 
	{
		$this->arr = array('item');
		var_dump(key($this->arr)); // dumps 0
		
		// this unexpectedly advances the internal array pointer
		foreach ($this->getArr() as $v) {}
		
		var_dump(key($this->arr)); // dumps NULL
	}

	function getArr()
	{
		// is NOT returned by reference
		return $this->arr;
	}
}

$test = new Test;
$test->run();
?>
--EXPECT--
int(0)
NULL
