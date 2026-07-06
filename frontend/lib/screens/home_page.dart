import 'package:flutter/material.dart';
import 'package:place_prep/screens/application_page.dart';
import 'package:place_prep/screens/dsa_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleCard(
        title: 'DSA Page',
        subtitle: 'Practice and track DSA questions',
        icon: Icons.code,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DsaPage()),
          );
        },
      ),
      _ModuleCard(
        title: 'Applications',
        subtitle: 'Track company applications and statuses',
        icon: Icons.business,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplicationPage()),
          );
        },
      ),
      _ModuleCard(
        title: 'Projects',
        subtitle: 'Coming soon',
        icon: Icons.work_outline,
        onTap: null,
      ),
      _ModuleCard(
        title: 'Companies',
        subtitle: 'Coming soon',
        icon: Icons.business_outlined,
        onTap: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Prep'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a module',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The DSA tracker is ready. Other modules will be added here soon.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: modules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => modules[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: onTap == null
            ? const Chip(label: Text('Soon'))
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
