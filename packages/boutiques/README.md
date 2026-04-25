# boutiques_weebi

Boutique management package for Weebi with chain grouping, permissions management, and comprehensive UI components.

## Features

- **Chain & Boutique Management**: Read and display boutiques grouped by their chains
- **Access Control System**: Admin interface for defining which chains/boutiques users can access
- **Rich UI Components**: Beautiful widgets for listing, viewing, and managing boutiques
- **Route Integration**: Clean route builders that client apps can easily integrate
- **State Management**: Provider-based state management for chains and boutiques
- **Search & Filtering**: Search boutiques and chains by name and location

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  boutiques_weebi:
    path: ../boutiques
```

## Usage

### Basic Setup

1. **Wrap your app with the BoutiqueProvider**:

```dart
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoutiqueProvider(fenceServiceClient),
      child: MaterialApp(
        title: 'My App',
        routes: BoutiqueRoutes.getMaterialRoutes(),
        onGenerateRoute: BoutiqueRoutes.onGenerateRoute,
        home: MyHomePage(),
      ),
    );
  }
}
```

2. **Display boutiques grouped by chains**:

```dart
import 'package:boutiques_weebi/boutiques_weebi.dart';

class BoutiquePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boutiques')),
      body: BoutiqueListWidget(
        showChainHeaders: true,
        allowSelection: true,
        onBoutiqueSelected: (boutique) {
          print('Selected: ${boutique.displayName}');
        },
        onChainSelected: (chain) {
          print('Selected chain: ${chain.name}');
        },
      ),
    );
  }
}
```

### Access Control Management

For admins to define which chains and boutiques users can access:

```dart
import 'package:boutiques_weebi/boutiques_weebi.dart';

class UserAccessControlPage extends StatelessWidget {
  final String? userId; // Optional - can be used for user creation
  final Set<String>? currentChainAccess;
  final Set<String>? currentBoutiqueAccess;

  UserAccessControlPage({
    this.userId, // No longer required!
    this.currentChainAccess,
    this.currentBoutiqueAccess,
  });

  @override
  Widget build(BuildContext context) {
    return BoutiquePermissionsWidget(
      userId: userId, // Optional for display
      initialSelectedChainIds: currentChainAccess,
      initialSelectedBoutiqueIds: currentBoutiqueAccess,
      isEditable: true,
      onSelectionChanged: (chainIds, boutiqueIds) {
        // Save access control - no userId required in callback!
        print('Access updated: ${chainIds.length} chains, ${boutiqueIds.length} boutiques');
        // You can associate this with userId in your own logic
      },
    );
  }
}
```

### Using Routes

The package provides pre-built routes for easy navigation:

```dart
// Navigate to boutique list
BoutiqueRoutes.navigateToBoutiqueList(context);

// Navigate to access control management  
BoutiqueRoutes.navigateToBoutiquePermissions(
  context,
  userId: 'user123', // Optional!
  selectedChainIds: {'chain1', 'chain2'},
  selectedBoutiqueIds: {'boutique1', 'boutique2'},
  onSelectionChanged: (chainIds, boutiqueIds) {
    // Handle access changes
  },
);

// Navigate to boutique details
BoutiqueRoutes.navigateToBoutiqueDetail(context, boutique);

// Navigate to chain details
BoutiqueRoutes.navigateToChainDetail(context, chain);
```

### Custom Integration

For more control, use the widget builders directly:

```dart
// Custom scaffold with your own app bar and drawer
Widget customBoutiquePage = BoutiqueRoutes.buildBoutiqueListWithCustomScaffold(
  appBar: MyCustomAppBar(),
  drawer: MyCustomDrawer(),
  endDrawer: null,
  floatingActionButton: FloatingActionButton(
    onPressed: () => _createNewBoutique(),
    child: Icon(Icons.add),
  ),
);
```

### State Management

Access the boutique provider directly:

```dart
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BoutiqueProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }

        return Column(
          children: [
            Text('${provider.chains.length} chains'),
            Text('${provider.allBoutiques.length} total boutiques'),
            Text('${provider.activeBoutiques.length} active boutiques'),
            
            // Access selected items
            if (provider.selectedChain != null)
              Text('Selected chain: ${provider.selectedChain!.name}'),
            
            if (provider.selectedBoutique != null)
              Text('Selected boutique: ${provider.selectedBoutique!.displayName}'),
          ],
        );
      },
    );
  }
}
```

## API Reference

### Core Classes

- **BoutiqueProvider**: State management for chains and boutiques
- **ChainExtension**: Extension methods for Chain protobuf objects
- **BoutiqueMongoExtension**: Extension methods for BoutiqueMongo protobuf objects

### Widgets

- **BoutiqueListWidget**: Displays boutiques grouped by chains with search
- **BoutiquePermissionsWidget**: Admin interface for managing user access control (which chains/boutiques users can access)
- **BoutiqueDetailWidget**: Detailed view of a single boutique
- **ChainDetailWidget**: Detailed view of a chain and its boutiques

### Routes

- **BoutiqueRoutes**: Static class providing route builders and navigation helpers

### Key Features

#### Chain & Boutique Grouping
- Boutiques are automatically grouped by their parent chains
- Visual chain headers with boutique counts
- Expandable/collapsible chain sections

#### Access Control Management
- Visual selection of chains and boutiques for user access
- Hierarchical selection (selecting a chain selects all its boutiques)
- FAB (Floating Action Button) for saving changes
- No userId required - works for user creation scenarios

#### Search & Filtering
- Real-time search across boutique names and addresses
- Chain-level filtering
- Active/inactive status filtering

#### Beautiful UI
- Material Design components
- Status indicators for boutiques
- Logo display support
- Responsive layouts

## Example

See the `example/` directory for a complete implementation example.

## License

This project is licensed under the MIT License.
