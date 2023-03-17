import 'package:stock_vapes/utils/configs.dart';

class Repository {
  static Future<void> updateStock(int vapeId, int subtractStock) async {
    var currentVapestock = (await repositoryBase
            .collection("stock")
            .where("id", isEqualTo: vapeId)
            .get())
        .docs[0]
        .reference;
    await currentVapestock.update({
      "stock": (await currentVapestock.get()).data()!["stock"] - subtractStock
    });
  }
}
