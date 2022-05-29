build:
	fennel generate-api.fnl
	./fnlfmt --fix love-api.fnl
