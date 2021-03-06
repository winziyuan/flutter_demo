import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/common.dart';
import 'BookBeans.dart';
import 'BookDetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class SearchResultPage extends StatefulWidget {
	final String words;
	final ValueChanged<bool> hideBottom;

	SearchResultPage({this.words, this.hideBottom});

	@override
	_SearchResultPageState createState() =>
			new _SearchResultPageState(words: words, hideBottom: this.hideBottom);
}

class _SearchResultPageState extends State<SearchResultPage> {
	final String words;
	final ValueChanged<bool> hideBottom;

	_SearchResultPageState({this.words, this.hideBottom});

	@override
	void initState() {
		super.initState();
		loadData();
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
				elevation: Styles.Elevation,
				title: new Text("\"$words\"搜索结果"),
			),
			body: buildBody(),
		);
	}

	bool isLoading = true;
	bool isEmputy = false;
	var datas = new List<SearchItem>();

	Widget buildBody() {
		if (isLoading) {
			return new Center(child: new CircularProgressIndicator());
		}

		if (isEmputy) {
			return new Center(child: new Text("没有搜到内容"));
		} else {
			return new RefreshIndicator(
					child: buildlistView(), onRefresh: _onRefresh);
		}
	}

	Future loadData() async {
		var url = Common.book_baseurl + "/SearchBook.php?q=$words";
		var resp = await http.get(url);

		datas.clear();
		var list = parser.parse(resp.body).querySelectorAll("div.hot_sale");
		list.forEach((e) {
			var item = new SearchItem();
			item.name = e.querySelector("p.title").text;
			item.author = e.querySelectorAll("p.author")[0].text;
			item.newName = e.querySelectorAll("p.author")[1].text;
			item.bookid = e.querySelector("a").attributes["href"].replaceAll("/", "");
			datas.add(item);
		});

		setState(() {
			if (datas.length == 0) {
				isLoading = false;
				isEmputy = true;
			} else {
				isLoading = false;
			}
		});
	}

	Future<Null> _onRefresh() async {
		await loadData();
	}

	Widget buildlistView() {
		return new ListView.builder(
			itemCount: datas.length,
			itemBuilder: buildItem,
		);
	}

	Widget buildItem(BuildContext context, int index) {
		var item = datas[index];
		return new InkWell(
			onTap: () {
				var book = new BklistItem();
				book.bookID = item.bookid;
				book.author = item.author;
				Tools.startPage(context, new BookDetailPage(
					bookid: item.bookid, title: item.name,
				));
			},
			child: new Container(
				padding: new EdgeInsets.only(
						left: 10.0, right: 10.0, bottom: 5.0, top: 5.0),
				child: new Column(
					children: <Widget>[
						new Row(
							children: <Widget>[
								new Expanded(
										child: new Text(
											item.name.trim(),
											style: Styles.buildTitle(14),
										))
							],
						),
						new Row(
							children: <Widget>[
								new Expanded(
										child: new Text(
											item.author.trim(),
											style: Styles.buildSubTitle(12),
										))
							],
						),
						new Row(
							children: <Widget>[
								new Expanded(
										child: new Text(
											item.newName.trim(),
											style: Styles.buildSubTitle(12),
										))
							],
						),
					],
				),
				decoration: new BoxDecoration(
						border: new Border(bottom: new BorderSide(color: Styles.lineColor, width: 0.5))),
			));
	}
}
