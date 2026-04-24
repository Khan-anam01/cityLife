class JobModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final String? location;
  final String? salary;
  final String? type; // full-time, part-time, contract, internship
  final String? category;
  final String? skills;
  final DateTime? deadline;
  final bool isRemote;
  final String? logoUrl;
  final String? applyUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    this.location,
    this.salary,
    this.type,
    this.category,
    this.skills,
    this.deadline,
    this.isRemote = false,
    this.logoUrl,
    this.applyUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  List<String> get skillsList =>
      skills?.split(',').map((s) => s.trim()).toList() ?? [];

  String get typeLabel {
    switch (type) {
      case 'full-time':
        return 'Full-time';
      case 'part-time':
        return 'Part-time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      case 'freelance':
        return 'Freelance';
      default:
        return type ?? 'Job';
    }
  }

  bool get isExpired => deadline != null && deadline!.isBefore(DateTime.now());

  String get deadlineLabel {
    if (deadline == null) return 'Open';
    if (isExpired) return 'Expired';
    final days = deadline!.difference(DateTime.now()).inDays;
    if (days == 0) return 'Closes today';
    if (days == 1) return 'Closes tomorrow';
    return 'Closes in $days days';
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String,
      company: map['company'] as String,
      description: map['description'] as String,
      location: map['location'] as String?,
      salary: map['salary'] as String?,
      type: map['type'] as String?,
      category: map['category'] as String?,
      skills: map['skills'] as String?,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      isRemote: (map['is_remote'] as int? ?? 0) == 1,
      logoUrl: map['logo_url'] as String?,
      applyUrl: map['apply_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'company': company,
        'description': description,
        'location': location,
        'salary': salary,
        'type': type,
        'category': category,
        'skills': skills,
        'deadline': deadline?.toIso8601String(),
        'is_remote': isRemote ? 1 : 0,
        'logo_url': logoUrl,
        'apply_url': applyUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
