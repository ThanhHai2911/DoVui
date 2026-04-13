import 'package:dovui/pages/room/widgets/join_room_sheet.dart';
import 'package:dovui/pages/room/room_lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/room_bloc.dart';
import 'bloc/room_event.dart';
import 'bloc/room_state.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen>
    with SingleTickerProviderStateMixin {
  final _passwordCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentUserId = prefs.getString('userId') ?? '');
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── KHÔNG có BlocProvider ở đây nữa ──
    return BlocConsumer<RoomBloc, RoomState>(
      listener: (context, state) {
        if (state.status == RoomStatus.waiting && state.room != null) {
          final bloc = context.read<RoomBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider.value(
                    value: bloc,
                    child: RoomLobbyScreen(currentUserId: _currentUserId,initialRoomId: state.room!.roomId,),
                  ),
            ),
          );
        }
        if (state.status == RoomStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFE24B4A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child:
                        state.status == RoomStatus.loading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6C63FF),
                              ),
                            )
                            : _buildContent(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: Color(0xFF1E1B4B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tạo phòng chơi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showJoinSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded, size: 15, color: Color(0xFF6C63FF)),
                  SizedBox(width: 5),
                  Text(
                    'Vào phòng',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, RoomState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Chọn chủ đề'),
          const SizedBox(height: 10),
          _buildCategoryGrid(context, state),
          const SizedBox(height: 20),
          _sectionTitle('Mật khẩu phòng'),
          const SizedBox(height: 10),
          _buildPasswordField(),
          const SizedBox(height: 28),
          _buildCreateButton(context, state),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1E1B4B),
    ),
  );

  Widget _buildCategoryGrid(BuildContext context, RoomState state) {
    if (state.categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final cat = state.categories[index];
        final isSelected = cat.id == state.selectedCategoryId;

        return GestureDetector(
          onTap:
              () => context.read<RoomBloc>().add(
                SelectCategory(
                  categoryId: cat.id,
                  categoryName: cat.name,
                  categoryType: cat.type, // ← truyền type
                ),
              ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _passwordCtrl,
        decoration: InputDecoration(
          hintText: 'Để trống nếu không cần mật khẩu',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, RoomState state) {
    final canCreate = state.selectedCategoryId.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            canCreate
                ? () {
                  context.read<RoomBloc>().add(
                    CreateRoom(
                      categoryId: state.selectedCategoryId,
                      categoryName: state.selectedCategoryName,
                      type: state.selectedCategoryType, // ← truyền type
                      password: _passwordCtrl.text.trim(),
                      questionCount: state.questionCount,
                      timePerQuestion: state.timePerQuestion,
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          disabledBackgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Tạo phòng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showJoinSheet(BuildContext context) {
    final bloc = context.read<RoomBloc>(); // ← lưu trước
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => BlocProvider.value(
            value: bloc,
            child: JoinRoomSheet(currentUserId: _currentUserId),
          ),
    );
  }
}
