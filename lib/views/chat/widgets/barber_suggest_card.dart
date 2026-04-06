import 'package:flutter/material.dart';
import 'package:barbergofe/models/chat/barber_search_response.dart';

class BarberSuggestCard extends StatelessWidget {
  final BarberSearchResult result;
  final VoidCallback onTap;

  const BarberSuggestCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.cut, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    result.barberName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (result.area.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 11, color: Colors.white38),
                  const SizedBox(width: 2),
                  Text(
                    result.area,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              result.output,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${(result.similarity * 100).toStringAsFixed(0)}% phù hợp',
                style: const TextStyle(color: Colors.amber, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}