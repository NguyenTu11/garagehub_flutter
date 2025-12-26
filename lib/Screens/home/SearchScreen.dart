import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _results = [];
  bool _isSearching = false;

  void _onSearch(String query) {
    setState(() {
      _isSearching = true;
      // Fake search logic, replace with real API
      _results = query.isEmpty
          ? []
          : List.generate(5, (i) => 'Kết quả cho "$query" #${i + 1}');
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardRadius = 28;
    final Color mainBlue = Colors.blue.shade700;
    final Color headerBlue = Colors.blue.shade100; // Light blue
    final Color lightBlue = Colors.blue.shade50;
    final Color accentBlue = Colors.blue.shade400;
    final Color shadowBlue = Colors.blue.shade100.withOpacity(0.18);

    return SafeArea(
      child: Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          backgroundColor: headerBlue,
          elevation: 10,
          title: Text(
            'Tìm kiếm',
            style: TextStyle(
              color: mainBlue,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.1,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: mainBlue),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8),
              AnimatedContainer(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: shadowBlue,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onSearch,
                        style: TextStyle(fontSize: 16, color: mainBlue),
                        decoration: InputDecoration(
                          hintText: 'Nhập từ khóa...',
                          hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: accentBlue,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: _controller.text.isNotEmpty
                          ? IconButton(
                              key: ValueKey('clear'),
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.blue.shade300,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                  _results = [];
                                });
                              },
                            )
                          : SizedBox(width: 0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Kết quả tìm kiếm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: mainBlue,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 18),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Không có kết quả',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => SizedBox(height: 14),
                        itemBuilder: (context, i) => Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [accentBlue, mainBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              _results[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: mainBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
