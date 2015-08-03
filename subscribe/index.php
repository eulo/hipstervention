<?php
  if (!isset($_POST)) die;
  header('Content-Type: application/json');

  # Includes
  require_once 'settings.php';
  require_once 'createsend-php/csrest_subscribers.php';
  require_once 'createsend-php/csrest_lists.php';

  # Validation
  $customer_data = $_POST;

  $required_fields = array(
    'firstname', 'lastname', 'email', 'address', 'state', 'suburb', 'postcode'
  );
  foreach ($required_fields as $key) {
    if (!array_key_exists($key, $_POST) || $_POST[$key] == '') {
      echo json_encode(array(
        'success' => false,
        'error' => "Missing field: $key",
        'field' => $key
      ));
      die;
    }
  }


  $auth = array('api_key' => $config['API_KEY']);

  $wrap = new CS_REST_Lists($config['LIST_ID'], $auth);
  $result = $wrap->get_active_subscribers();

  if ($result->was_successful()) {
    if ($result->response->TotalNumberOfRecords >= 2000) {
      echo json_encode(array(
        'success' => true,
        'error' => 'Subscription full'
      ));
      die;
    }
  } else {
    echo json_encode(array(
      'success' => false,
      'error' => 'Couldn\'t retrieve list length'
    ));
    die;
  }

  $wrap = null;
  $wrap = new CS_REST_Subscribers($config['LIST_ID'], $auth);


  $headers = array(
    'Accept' => 'application/json'
  );
  $options = array(
  );
  $send_data = array(
    'EmailAddress' => $customer_data['email'],
    'Name' => $customer_data['firstname'] . ' ' . $customer_data['lastname'],
    'CustomFields' => array (
      array (
        'Key' => '[FirstName1]',
        'Value' => $customer_data['firstname'],
      ),
      array (
        'Key' => '[LastName1]',
        'Value' => $customer_data['lastname'],
      ),
      array (
        'Key' => '[Address]',
        'Value' => $customer_data['address'],
      ),
      array (
        'Key' => '[Suburb]',
        'Value' => $customer_data['suburb'],
      ),
      array (
        'Key' => '[State]',
        'Value' => $customer_data['state'],
      ),
      array (
        'Key' => '[Postcode]',
        'Value' => $customer_data['postcode'],
      ),
    ),
    'Resubscribe' => true,
  );

  $result = $wrap->add($send_data);
  echo json_encode(array('success' => $result->was_successful() ));
  die;

?>
