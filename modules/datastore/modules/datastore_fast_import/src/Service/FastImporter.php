<?php

namespace Drupal\datastore_fast_import\Service;

use Dkan\Datastore\Importer;
use Drupal\Core\Database\Database;
use Procrastinator\Result;

/**
 * Class FastImporter.
 *
 * @package Drupal\datastore_fast_import\Service
 */
class FastImporter extends Importer {

  /**
   * Override.
   *
   * {@inheritdoc}
   */
  protected function runIt() {
    $fileSystem = \Drupal::service('file_system');
    $filename = $fileSystem->realpath($this->resource->getFilePath());

    $f = fopen($filename, 'r');
    $line = fgets($f);
    fclose($f);
    $header = str_getcsv($line);
    $header = $this->cleanHeaders($header);

    $this->setStorageSchema($header);

    /* @var $storage \Drupal\datastore\Storage\DatabaseTable */
    $storage = $this->dataStorage;
    $storage->count();

    $sqlStatementLines = [
      'LOAD DATA LOCAL INFILE \'' . $filename . '\'',
      'INTO TABLE ' . $storage->getTableName(),
      'FIELDS TERMINATED BY \',\'',
      'ENCLOSED BY \'\"\'',
      'LINES TERMINATED BY \'\n\'',
      'IGNORE 1 ROWS',
      '(' . implode(',', $header) . ')',
      'SET record_number = NULL;',
    ];

    $sqlStatement = implode(' ', $sqlStatementLines);

    $db = $this->getDatabaseConnectionCapableOfDataLoad();
    $db->query($sqlStatement)->execute();

    Database::setActiveConnection();

    $this->getResult()->setStatus(Result::DONE);

    return $this->getResult();
  }

  /**
   * Private.
   */
  private function getDatabaseConnectionCapableOfDataLoad() {
    $options = \Drupal::database()->getConnectionOptions();
    $options['pdo'][\PDO::MYSQL_ATTR_LOCAL_INFILE] = 1;
    Database::addConnectionInfo('extra', 'default', $options);
    Database::setActiveConnection('extra');

    return Database::getConnection();
  }

  /**
   * Private.
   */
  private function cleanHeaders($headers) {
    $row = [];
    foreach ($headers as $field) {
      $new = preg_replace("/[^A-Za-z0-9_ ]/", '', $field);
      $new = trim($new);
      $new = strtolower($new);
      $new = str_replace(" ", "_", $new);

      $mysqlMaxColLength = 64;
      if (strlen($new) > $mysqlMaxColLength) {
        $strings = str_split($new, $mysqlMaxColLength - 5);
        $token = substr(md5($field), 0, 4);
        $new = $strings[0] . "_{$token}";
      }

      $row[] = $new;
    }
    return $row;
  }

}
