{ stdenv, buildPythonPackage, fetchPypi, pyhcl, requests }:

buildPythonPackage rec {
  pname = "hvoc";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0p3ka875n0qmdkrjffvqgcj3pbl002srrlcjdk8pyhhwg6b78d4l7";
  };


  propagatedBuildInputs = [ requests pyhcl ];

  #
  doCheck = false;

  meta = with stdenv.lib; {
    description = ""HashiCorp Vault API client;
    homepage = https://github.com/hvac/hvac;
    license = licenses.asl20;
    maintainers = with maintainers; [ psyanticy ];
  };
}
