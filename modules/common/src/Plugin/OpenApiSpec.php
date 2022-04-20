<?php

namespace Drupal\common\Plugin;

use RootedData\RootedJsonData;

/**
 * DatastoreQuery.
 */
class OpenApiSpec extends RootedJsonData {

  /**
   * Constructor.
   *
   * @param string $json
   *   JSON query string from API payload.
   */
  public function __construct(string $json) {
    parent::__construct($json, '{}');
  }

}
