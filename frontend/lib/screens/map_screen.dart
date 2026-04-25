import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _accent = Color(0xFFFF5414);
const _bg = Color(0xFF0B1416);
const _card = Color(0xFF1A2A30);

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── 1. THE REAL INTERACTIVE MAP (LIVE FROM FIREBASE) ──
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('map_nodes')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading map data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: _accent),
                );
              }

              // Convert Firebase documents into Flutter Map Markers
              final markers = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                Color nodeColor = Colors.greenAccent;
                bool shouldPulse = false;

                // Safely extract data
                final status = data['status'] ?? 'stable';
                final name = data['name'] ?? 'Unknown';
                final desc = data['desc'] ?? '';
                final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
                final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;

                // Pick color based on status
                if (status == 'critical') {
                  nodeColor = Colors.redAccent;
                  shouldPulse = true;
                } else if (status == 'high') {
                  nodeColor = Colors.orangeAccent;
                  shouldPulse = true;
                } else if (status == 'moderate') {
                  nodeColor = Colors.yellowAccent;
                } else if (status == 'improving') {
                  nodeColor = Colors.lightBlueAccent;
                }

                return Marker(
                  point: LatLng(lat, lng),
                  width: 150,
                  height: 80,
                  child: _buildNode(
                    context: context,
                    color: nodeColor,
                    label: name,
                    sublabel: desc,
                    pulse: shouldPulse,
                  ),
                );
              }).toList();

              return FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(
                    4.2105,
                    108.9758,
                  ), // Centers perfectly on Malaysia
                  initialZoom: 6.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          // ── 2. VIGNETTE OVERLAY ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. TOP LEFT PANEL ──
          Positioned(
            top: 24,
            left: 24,
            child: _buildGlassPanel(
              width: 300,
              opacity: 0.82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.radar, color: _accent, size: 22),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Live Community Resilience Map',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Héalance AI monitors anonymous engagement data across Malaysian districts to identify mental health resource deserts in real time.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _legendRow(Colors.redAccent, 'Critical Desert'),
                  const SizedBox(height: 4),
                  _legendRow(Colors.orangeAccent, 'High Tension'),
                  const SizedBox(height: 4),
                  _legendRow(Colors.yellowAccent, 'Moderate'),
                  const SizedBox(height: 4),
                  _legendRow(Colors.greenAccent, 'Stable'),
                  const SizedBox(height: 4),
                  _legendRow(Colors.lightBlueAccent, 'Improving'),
                ],
              ),
            ),
          ),

          // ── 4. BOTTOM RIGHT PANEL ──
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildGlassPanel(
              width: 290,
              opacity: 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Insights — Last 24 Hours',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  _insightRow(
                    Icons.warning_amber_rounded,
                    Colors.redAccent,
                    'Burnout spike in Subang Jaya. 3 universities, no 24/7 youth clinic nearby.',
                  ),
                  const SizedBox(height: 10),
                  _insightRow(
                    Icons.warning_amber_rounded,
                    Colors.orangeAccent,
                    'Kota Bharu: Critical Desert. Highest Dark Thoughts posts per capita.',
                  ),
                  const SizedBox(height: 10),
                  _insightRow(
                    Icons.check_circle_outline,
                    Colors.greenAccent,
                    'Penang stable after new campus counselling rollout.',
                  ),
                  const SizedBox(height: 10),
                  _insightRow(
                    Icons.trending_up,
                    Colors.lightBlueAccent,
                    'Miri resilience improved 18% — new clinic opened.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Wire up deployment action
                      },
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text('Deploy Digital Resources'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. BOTTOM LEFT STATS ──
          Positioned(
            bottom: 24,
            left: 24,
            child: _buildGlassPanel(
              width: 200,
              opacity: 0.82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Malaysia Overview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _statRow('Active Spaces', '19', Colors.tealAccent),
                  const SizedBox(height: 6),
                  _statRow('Posts Today', '847', Colors.amber),
                  const SizedBox(height: 6),
                  _statRow('Districts Monitored', '13', Colors.lightBlueAccent),
                  const SizedBox(height: 6),
                  _statRow('Critical Zones', '3', Colors.redAccent),
                  const SizedBox(height: 6),
                  _statRow('Resources Deployed', '42', Colors.greenAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET EXTRACTS ──

  Widget _buildNode({
    required BuildContext context,
    required Color color,
    required String label,
    required String sublabel,
    required bool pulse,
  }) {
    return GestureDetector(
      onTap: () {
        // Safe, clean interactivity added here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label: $sublabel'),
            backgroundColor: _card,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (pulse)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: pulse ? 10 : 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _card.withOpacity(0.90),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: color.withOpacity(0.3), width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(sublabel, style: TextStyle(color: color, fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPanel({
    required double width,
    required Widget child,
    double opacity = 0.85,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card.withOpacity(opacity),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _insightRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
