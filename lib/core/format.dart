String two(int n) => n.toString().padLeft(2, '0');

String fmtTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

String fmtDate(DateTime d) => '${two(d.day)}/${two(d.month)}/${d.year}';

String fmtWhen(DateTime d) {
  final now = DateTime.now();
  final same = d.year == now.year && d.month == now.month && d.day == now.day;
  return same ? 'Auj. ${fmtTime(d)}' : '${fmtDate(d)} ${fmtTime(d)}';
}
