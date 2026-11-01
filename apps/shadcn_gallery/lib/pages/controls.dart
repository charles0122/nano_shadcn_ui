import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import '../gallery_kit.dart';

// --- Button -----------------------------------------------------------------

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NanoButton(label: 'Primary', onPressed: () {}),
            NanoButton(
              label: 'Secondary',
              variant: NanoButtonVariant.secondary,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Destructive',
              variant: NanoButtonVariant.destructive,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Outline',
              variant: NanoButtonVariant.outline,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Ghost',
              variant: NanoButtonVariant.ghost,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Link',
              variant: NanoButtonVariant.link,
              onPressed: () {},
            ),
            const NanoButton(label: 'Disabled'),
          ],
        ),
        SizedBox(height: NanoTheme.of(context).spacing.stackDefault),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NanoButton(
              label: 'Compact',
              size: NanoButtonSize.compact,
              icon: NanoIcons.mail,
              onPressed: () {},
            ),
            NanoButton(label: 'Medium', icon: NanoIcons.mail, onPressed: () {}),
            NanoButton(
              label: 'Large',
              size: NanoButtonSize.large,
              icon: NanoIcons.mail,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Icon',
              size: NanoButtonSize.icon,
              variant: NanoButtonVariant.outline,
              icon: NanoIcons.chevronRight,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// --- Checkbox ---------------------------------------------------------------

class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo();

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  bool _single = false;
  NanoTristate _tristate = NanoTristate.mixed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoCheckbox(
          value: NanoCheckbox.of(_single),
          label: 'Accept terms and conditions',
          onChanged: (v) => setState(() => _single = v == NanoTristate.checked),
        ),
        SizedBox(height: NanoTheme.of(context).spacing.stackDefault),
        NanoCheckbox(
          value: _tristate,
          label: 'Select all (mixed state)',
          onChanged: (v) => setState(() {
            _tristate = v == NanoTristate.checked
                ? NanoTristate.unchecked
                : NanoTristate.checked;
          }),
        ),
        SizedBox(height: NanoTheme.of(context).spacing.stackDefault),
        const NanoCheckbox(
          value: NanoTristate.checked,
          enabled: false,
          label: 'Disabled',
        ),
      ],
    );
  }
}

// --- Radio ------------------------------------------------------------------

class _RadioDemo extends StatefulWidget {
  const _RadioDemo();

  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String _plan = 'pro';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: NanoRadioGroup<String>(
        value: _plan,
        onChanged: (v) => setState(() => _plan = v ?? 'pro'),
        children: [
          NanoRadioTile(
            value: 'free',
            title: 'Free',
            subtitle: 'Up to 3 projects · community support.',
          ),
          NanoRadioTile(
            value: 'pro',
            title: 'Pro',
            subtitle: 'Unlimited projects · priority support.',
            trailing: const NanoBadge(
              '\$20/mo',
              variant: NanoBadgeVariant.secondary,
            ),
          ),
          NanoRadioTile(
            value: 'team',
            title: 'Team',
            subtitle: 'Everything in Pro, plus shared workspaces.',
            trailing: const NanoBadge(
              '\$60/mo',
              variant: NanoBadgeVariant.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Switch -----------------------------------------------------------------

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _airplane = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NanoSwitch(
              value: _airplane,
              onChanged: (v) => setState(() => _airplane = v),
            ),
            SizedBox(width: theme.spacing.inlineIconLabel),
            NanoText('Airplane Mode', role: NanoTextRole.body),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NanoSwitch(
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            SizedBox(width: theme.spacing.inlineIconLabel),
            NanoText('Notifications', role: NanoTextRole.body),
          ],
        ),
      ],
    );
  }
}

// --- Slider -----------------------------------------------------------------

class _SliderDemo extends StatefulWidget {
  const _SliderDemo();

  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  List<double> _single = [0.4];
  List<double> _range = [0.25, 0.75];

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoSlider(
            values: _single,
            divisions: 20,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _single = v),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoText(
            'Value: ${(_single.first * 100).round()}%',
            role: NanoTextRole.labelMetadata,
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoSlider(
            values: _range,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _range = v),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoText(
            'Range: ${(_range.first * 100).round()}% – ${(_range.last * 100).round()}%',
            role: NanoTextRole.labelMetadata,
          ),
        ],
      ),
    );
  }
}

// --- Toggle & group ----------------------------------------------------------

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  bool _bold = true;
  List<int> _group = const [0];

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoToggle(
          pressed: _bold,
          icon: NanoIcons.bold,
          onPressed: () => setState(() => _bold = !_bold),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoToggleGroup(
          value: _group,
          onChanged: (v) => setState(() => _group = v),
          children: const [
            NanoToggle(pressed: false, icon: NanoIcons.bold),
            NanoToggle(pressed: false, icon: NanoIcons.italic),
            NanoToggle(pressed: false, icon: NanoIcons.underline),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          'Group selection: ${_group.map((i) => ['bold', 'italic', 'underline'][i]).join(', ')}',
          role: NanoTextRole.labelMetadata,
        ),
      ],
    );
  }
}

// --- Input / textarea / group ------------------------------------------------

class _InputDemo extends StatelessWidget {
  const _InputDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NanoInput(
            label: 'Name',
            placeholder: 'Ada Lovelace',
            fillWidth: true,
          ),
          SizedBox(height: theme.spacing.stackDefault),
          const NanoInput(
            label: 'Disabled',
            placeholder: 'Not editable',
            enabled: false,
            fillWidth: true,
          ),
          SizedBox(height: theme.spacing.stackDefault),
          // Input group: leading icon + trailing shortcut.
          NanoInput(
            label: 'Search',
            placeholder: 'Search the docs…',
            fillWidth: true,
            prefix: NanoIcon(
              NanoIcons.search,
              size: theme.size.iconInline,
              color: theme.colors.textSecondary,
            ),
            suffix: const NanoKbd(['⌘', 'K']),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          // Textarea = multiline input.
          const NanoInput(
            label: 'Bio',
            placeholder: 'Tell us a little bit about yourself',
            maxLines: 4,
            fillWidth: true,
          ),
        ],
      ),
    );
  }
}

// --- Input OTP ---------------------------------------------------------------

class _OTPDemo extends StatefulWidget {
  const _OTPDemo();

  @override
  State<_OTPDemo> createState() => _OTPDemoState();
}

class _OTPDemoState extends State<_OTPDemo> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoInputOTP(
          length: 6,
          value: _code,
          onChanged: (v) => setState(() => _code = v),
          onCompleted: (v) => NanoToast.show(
            context,
            title: 'Code complete',
            description: v,
            variant: NanoToastVariant.success,
          ),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          _code.isEmpty
              ? 'Click the cells and type — auto advance, backspace retract.'
              : 'Enter your verification code.',
          role: NanoTextRole.labelMetadata,
        ),
      ],
    );
  }
}

// --- Form -------------------------------------------------------------------

class _FormDemo extends StatefulWidget {
  const _FormDemo();

  @override
  State<_FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<_FormDemo> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  String? _nameError;
  String? _emailError;

  void _submit() {
    setState(() {
      _nameError = _name.text.trim().isEmpty
          ? 'Username must not be empty.'
          : null;
      _emailError = !_email.text.contains('@')
          ? 'Enter a valid email address.'
          : null;
    });
    if (_nameError == null && _emailError == null) {
      NanoToast.show(
        context,
        title: 'Profile updated',
        description: 'Validation passed for ${_email.text}',
        variant: NanoToastVariant.success,
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoFormItem(
            label: 'Username',
            description: 'This is your public display name.',
            error: _nameError,
            child: NanoInput(
              controller: _name,
              placeholder: 'ada',
              fillWidth: true,
            ),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoFormItem(
            label: 'Email',
            error: _emailError,
            child: NanoInput(
              controller: _email,
              placeholder: 'ada@nano.dev',
              keyboardType: TextInputType.emailAddress,
              fillWidth: true,
            ),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoButton(
            label: 'Update account',
            size: NanoButtonSize.compact,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

// --- Select -----------------------------------------------------------------

class _SelectDemo extends StatefulWidget {
  const _SelectDemo();

  @override
  State<_SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<_SelectDemo> {
  String? _framework = 'Flutter';
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoSelect<String>(
            fillWidth: true,
            items: const [
              NanoSelectItem(value: 'Flutter', label: 'Flutter'),
              NanoSelectItem(value: 'Dart', label: 'Dart'),
              NanoSelectItem(value: 'Nano', label: 'nano_ui', enabled: false),
            ],
            value: _framework,
            onChanged: (v) => setState(() => _framework = v),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          Row(
            children: [
              Expanded(
                child: NanoText('Email notifications', role: NanoTextRole.body),
              ),
              NanoSwitch(
                value: _emailNotifications,
                onChanged: (v) => setState(() => _emailNotifications = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Combobox ---------------------------------------------------------------

class _ComboboxDemo extends StatefulWidget {
  const _ComboboxDemo();

  @override
  State<_ComboboxDemo> createState() => _ComboboxDemoState();
}

class _ComboboxDemoState extends State<_ComboboxDemo> {
  List<String> _values = const ['flutter'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: NanoCombobox<String>(
        items: const [
          NanoComboboxItem(value: 'flutter', label: 'Flutter'),
          NanoComboboxItem(value: 'dart', label: 'Dart'),
          NanoComboboxItem(value: 'tokens', label: 'Design Tokens'),
          NanoComboboxItem(value: 'a2ui', label: 'A2UI'),
          NanoComboboxItem(value: 'registry', label: 'Component Registry'),
        ],
        values: _values,
        multiple: true,
        searchPlaceholder: 'Search frameworks…',
        onChanged: (v) => setState(() => _values = v),
      ),
    );
  }
}

// --- Command ----------------------------------------------------------------

class _CommandDemo extends StatelessWidget {
  const _CommandDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoButton(
          label: 'Open command dialog',
          variant: NanoButtonVariant.outline,
          icon: NanoIcons.search,
          onPressed: () => NanoCommandDialog.show(
            context,
            items: [
              NanoCommandItem(
                label: 'Calendar',
                icon: NanoIcons.calendar,
                group: 'Suggestions',
                shortcut: const ['⌘', 'C'],
                onSelect: () {},
              ),
              NanoCommandItem(
                label: 'Search emoji',
                icon: NanoIcons.smile,
                group: 'Suggestions',
                onSelect: () {},
              ),
              NanoCommandItem(
                label: 'Theme',
                icon: NanoIcons.palette,
                group: 'Settings',
                onSelect: () {},
              ),
              NanoCommandItem(
                label: 'Log out',
                icon: NanoIcons.logOut,
                group: 'Settings',
                shortcut: const ['⇧', '⌘', 'Q'],
                onSelect: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          '…or press ⌘K / Ctrl+K anywhere in this gallery.',
          role: NanoTextRole.labelMetadata,
        ),
      ],
    );
  }
}

// --- Calendar & date picker ---------------------------------------------------

class _CalendarDemo extends StatefulWidget {
  const _CalendarDemo();

  @override
  State<_CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<_CalendarDemo> {
  List<DateTime> _selected = [];
  List<DateTime> _range = [];

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoCalendar(
          month: DateTime(now.year, now.month),
          selected: _selected,
          onChanged: (v) => setState(() => _selected = v),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          'Selected: ${_selected.map((d) => '${d.month}/${d.day}').join(', ')}',
          role: NanoTextRole.labelMetadata,
        ),
        SizedBox(height: theme.spacing.stackSections),
        NanoCalendar(
          month: DateTime(now.year, now.month),
          selected: _range,
          mode: NanoCalendarMode.range,
          onChanged: (v) => setState(() => _range = v),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          'Range: ${_range.map((d) => '${d.month}/${d.day}').join(' → ')}',
          role: NanoTextRole.labelMetadata,
        ),
      ],
    );
  }
}

class _DatePickerDemo extends StatefulWidget {
  const _DatePickerDemo();

  @override
  State<_DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<_DatePickerDemo> {
  List<DateTime> _date = [];

  @override
  Widget build(BuildContext context) {
    return NanoDatePicker(
      value: _date,
      onChanged: (v) => setState(() => _date = v),
      fillWidth: true,
    );
  }
}

Widget buttonPage(BuildContext context) {
  return const DemoSection(
    title: 'Button',
    description: 'Six variants, four sizes, optional lucide icons.',
    child: _ButtonDemo(),
  );
}

Widget checkboxPage(BuildContext context) {
  return const DemoSection(
    title: 'Checkbox',
    description: 'Checked / unchecked / mixed, with a label tap target.',
    align: AlignmentDirectional.centerStart,
    child: _CheckboxDemo(),
  );
}

Widget radioGroupPage(BuildContext context) {
  return const DemoSection(
    title: 'Radio Group',
    description:
        'Card-style radio tiles — selection borders come from the '
        'focus ring token.',
    align: AlignmentDirectional.centerStart,
    child: _RadioDemo(),
  );
}

Widget switchPage(BuildContext context) {
  return const DemoSection(
    title: 'Switch',
    description: 'Track-and-thumb toggle animated with motion tokens.',
    child: _SwitchDemo(),
  );
}

Widget sliderPage(BuildContext context) {
  return const DemoSection(
    title: 'Slider',
    description: 'Single value and range dragging with snap divisions.',
    child: _SliderDemo(),
  );
}

Widget togglePage(BuildContext context) {
  return const DemoSection(
    title: 'Toggle & Toggle Group',
    description: 'Pressed-state buttons; the group merges borders.',
    child: _ToggleDemo(),
  );
}

Widget inputPage(BuildContext context) {
  return const DemoSection(
    title: 'Input · Input Group · Textarea',
    description:
        'One field core: label, prefix/suffix group, and multiline '
        'textarea mode.',
    align: AlignmentDirectional.centerStart,
    child: _InputDemo(),
  );
}

Widget inputOTPPage(BuildContext context) {
  return const DemoSection(
    title: 'Input OTP',
    description: 'Per-character cells with auto advance and group gaps.',
    child: _OTPDemo(),
  );
}

Widget formPage(BuildContext context) {
  return const DemoSection(
    title: 'Form',
    description:
        'Field composition with description and validation errors '
        'pushed into the controls.',
    align: AlignmentDirectional.centerStart,
    child: _FormDemo(),
  );
}

Widget selectPage(BuildContext context) {
  return const DemoSection(
    title: 'Select',
    description: 'Field-like trigger opening a check-marked option panel.',
    align: AlignmentDirectional.centerStart,
    child: _SelectDemo(),
  );
}

Widget comboboxPage(BuildContext context) {
  return const DemoSection(
    title: 'Combobox',
    description: 'Searchable multi-select over the option list.',
    align: AlignmentDirectional.centerStart,
    child: _ComboboxDemo(),
  );
}

Widget commandPage(BuildContext context) {
  return const DemoSection(
    title: 'Command',
    description:
        'cmdk-style palette: grouped filtered list with keyboard '
        'navigation.',
    child: _CommandDemo(),
  );
}

Widget calendarPage(BuildContext context) {
  return const DemoSection(
    title: 'Calendar',
    description: 'Month grid — single and range selection.',
    child: _CalendarDemo(),
  );
}

Widget datePickerPage(BuildContext context) {
  return const DemoSection(
    title: 'Date Picker',
    description: 'Field trigger hosting the calendar in a popover.',
    align: AlignmentDirectional.centerStart,
    child: SizedBox(width: 320, child: _DatePickerDemo()),
  );
}
