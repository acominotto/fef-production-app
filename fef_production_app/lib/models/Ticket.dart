/*
export const Ticket = z.object({
  weight: z.number().nullish(),
  pieces: z.number().nullish(),
  client: z.string(),
  product: z.string(),
});
*/

class Ticket {
  final num? weight;
  final num? pieces;
  final String client;
  final String product;

  Ticket(this.weight, this.pieces, this.client, this.product);

  Ticket.fromJson(Map<String, dynamic> json)
      : weight = json['weight'],
        pieces = json['pieces'],
        client = json['client'],
        product = json['product'];

  Map<String, dynamic> toJson() => {
        'weight': weight ?? 0,
        'pieces': pieces ?? 0,
        'client': client,
        'product': product,
      };
}
