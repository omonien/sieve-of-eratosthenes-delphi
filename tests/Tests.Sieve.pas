unit Tests.Sieve;

interface

uses
  System.Classes, System.SysUtils,
  DUnitX.TestFramework,
  SieveOfEratosthenes;

type

  [TestFixture]
  TTestSieve = class
  public
    [Test]
    [TestCase('Test 10000', '10000, 9973')]
    [TestCase('Test 100000', '100000, 99991')]
    // Test a couple of prime numbers by finding the largest prime below AMay
    // https://de.wikibooks.org/wiki/Primzahlen:_Tabelle_der_Primzahlen_(2_-_100.000)
    procedure TestMaxPrime(const AMax: Integer; const AMaxPrime: Integer);

    [Test]
    procedure TestOneNotPrime;

    [Test]
    [TestCase('pi(1000000)', '1000000, 78498')]
    //Test the PI fuction for a given value (ANumber)
    //https://de.wikipedia.org/wiki/Primzahl#Pi-Funktion_und_Primzahlsatz
    procedure TestPiFunction(const ANumber:integer; APiOfNumber: Integer);


  end;

implementation

procedure TTestSieve.TestMaxPrime(const AMax: Integer; const AMaxPrime: Integer);
begin
  var LPrimes := TSieveOfEratosthenes.GetPrimes(AMax);
  Assert.AreEqual<UInt32>(AMaxPrime, LPrimes[high(LPrimes)]);
end;

procedure TTestSieve.TestOneNotPrime;
begin
 var LPrimes := TSieveOfEratosthenes.GetPrimes(10);
 Assert.IsTrue(Length(LPrimes) = 4); //2,3,5,7
 Assert.AreEqual(2, LPrimes[0]); //1st is 2
end;

procedure TTestSieve.TestPiFunction(const ANumber:integer; APiOfNumber: Integer);
begin
  //pi(ANumber) = Length of result array
  var LPrimes := TSieveOfEratosthenes.GetPrimes(ANumber);
  Assert.AreEqual(APiOfNumber, Length(LPrimes));
end;

initialization

TDUnitX.RegisterTestFixture(TTestSieve);

end.
