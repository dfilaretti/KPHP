<?php
/**
     * Returns class of a type, used for functions available for type
     * or default values.
     *
     * @param string $type The data type to get a class.
     *
     * @return string
     *
     */
    public function getTypeClass($type)
    {
        $type = strtoupper($type);
        switch ($type) {
        case 'INTEGER':
        case 'BIGINT':
        case 'DECIMAL':
        case 'DOUBLE':
        case 'BOOLEAN':
        case 'SERIAL':
            return 'NUMBER';

        case 'DATE':
        case 'DATETIME':
        case 'TIMESTAMP':
        case 'TIME':
            return 'DATE';

        case 'VARCHAR':
        case 'TEXT':
        case 'VARBINARY':
        case 'BLOB':
        case 'ENUM':
            return 'CHAR';

        case 'UUID':
            return 'UUID';
        }
        return '';
    }
?>