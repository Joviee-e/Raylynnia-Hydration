import 'package:flutter/material.dart';
import '../../../../domain/entities/hydration_log.dart';

class DailyLogTile extends StatelessWidget {
  const DailyLogTile({
    required this.log,
    super.key,
  });

  final HydrationLog log;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_drink_outlined),
        title: Text('${log.volumeMl} ml'),
        subtitle: Text(
          '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Text(
          log.timestamp.toLocal().toString().split(' ')[0],
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
