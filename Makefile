hack_proxy:
	forge test -vvvv --match-test test_hackProxy
test_eip1967:
	forge test -vvvv --match-contract Answer1967ProxyTest
test_transparent:
	forge test -vvvv --match-contract TransparentUpgradeableProxyTest
test_uups:
	forge test -vvvv --match-contract UUPSProxyTest