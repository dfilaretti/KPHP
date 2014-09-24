<?php

	/**
     * Takes a string and outputs each character on a line for itself. Used
     * mainly for horizontalflipped display mode.
     * Takes care of special html-characters.
     * Fulfills https://sourceforge.net/p/phpmyadmin/feature-requests/164/
     *
     * @param string $string    The string
     * @param string $Separator The Separator (defaults to "<br />\n")
     *
     * @access  public
     * @todo    add a multibyte safe function PMA_STR_split()
     *
     * @return string      The flipped string
     */

    function flipstring($string/*, $Separator = "<br />\n"*/)
    {

        $format_string = '';
        $charbuff = false;

        for ($i = 0, $str_len = strlen($string); $i < $str_len; $i++) {
            $char = $string{$i};
            $append = false;

            if ($char == '&') {
                $format_string .= $charbuff;
                $charbuff = $char;
            } elseif ($char == ';' && ! empty($charbuff)) {
                $format_string .= $charbuff . $char;
                $charbuff = false;
                $append = true;
            } elseif (! empty($charbuff)) {
                $charbuff .= $char;
            } else {
                $format_string .= $char;
                $append = true;
            }

            // do not add separator after the last character
            if ($append && ($i != $str_len - 1)) {
                $format_string .= $Separator;
            }
        }

        return $format_string;

    }

$result = flipstring("abcd");
echo $result;
label("after-call");

?>