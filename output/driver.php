<?php
/*
 *  Clase singleton destinada a manejar cualquier interaccion con la base de datos
 *  Creada por Felipe Vieira para el proyecto de interfaces de usuario
 */
class Driver {
  private static $man = null;

  protected function Driver(){} // protegido el contructor para que no se puedan construir instancias desde fuera de la clase

  //Constructor singleton
  public static function getInstance(){
    if(isset(Driver::$man)){
      return Driver::$man;
    }else{
      Driver::$man = new Driver();
      Driver::$man->connect();
      return Driver::$man;
    }
  }

  //Conecta con la base de datos
  public function connect(){
    if(isset($this->db)){
      return true;
    }else{
      $this->db = new mysqli('localhost','AdminGSTR','AdminPass','GSTRDB');
      if ($this->db->connect_errno) {
          echo "error connecting to BBDD";
          die("Failed to connect to MySQL: " . $this->db->connect_error);
          return false;
      }
      return true;
    }
  }

  //Convierte el resultado de una query a un array
  private function returnArray($result){
    $arrayToReturn = array();
    while($r = $result->fetch_assoc()){
      array_push($arrayToReturn,$r);
    }
    return $arrayToReturn;
  }

  public function exec($query){
  $result = $this->db->query($query);
  if(!$result){
    die("Error en la query: ".$this->db->error);
  }
  if( ! is_bool($result)){
    return $this->returnArray($result);
  }
  return $result;
}
}
