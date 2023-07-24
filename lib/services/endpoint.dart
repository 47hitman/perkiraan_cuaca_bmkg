class endpoint {
  Future bmkg() async {
    // print(globals.token);
    final http.Response response = await http.get(
      Uri.parse('https://ibnux.github.io/BMKG-importer/cuaca/501233.json'),
    );
    print("code cuaca");
    print(response.request);
    print(response.body);
    print(response);
    return _response(response);
  }
}
