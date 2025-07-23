<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use Pages\ViewBanner;
use App\Models\Banner;
use Filament\Forms\Form;
use Filament\Tables\Table;
use Filament\Resources\Resource;
use Filament\Forms\Components\Grid;
use Filament\Tables\Actions\Action;
use Filament\Forms\Components\Section;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use App\Filament\Resources\BannerResource\Pages;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;

    protected static ?string $navigationIcon = 'heroicon-o-photo';

    protected static ?string $navigationGroup = 'Content Management';

    protected static ?string $navigationLabel = 'Banners';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Banner Information')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Forms\Components\TextInput::make('title')
                                    ->required()
                                    ->maxLength(255)
                                    ->live(onBlur: true)
                                    ->afterStateUpdated(function (string $context, $state, callable $set) {
                                        if ($context === 'create') {
                                            $set('button_text', 'Shop Now');
                                        }
                                    }),

                                Forms\Components\TextInput::make('subtitle')
                                    ->maxLength(255)
                                    ->placeholder('Optional subtitle'),
                            ]),

                        Forms\Components\Textarea::make('description')
                            ->maxLength(500)
                            ->rows(3)
                            ->placeholder('Optional description for the banner'),

                        Forms\Components\FileUpload::make('image_path')
                            ->label('Banner Image')
                            ->image()
                            ->storeFileNamesIn('image_path')
                            ->disk('public')
                            ->directory('banners')
                            ->imageEditor()
                            ->imageEditorAspectRatios([
                                '16:9',
                                '4:3',
                                '1:1',
                            ])
                            ->maxSize(2048)
                            ->required()
                            ->columnSpanFull(),
                    ]),

                Section::make('Banner Settings')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                Forms\Components\Select::make('position')
                                    ->options([
                                        'main' => 'Main Banner (Left Side)',
                                        'side_top' => 'Side Top Banner',
                                        'side_bottom' => 'Side Bottom Banner',
                                    ])
                                    ->required()
                                    ->native(false)
                                    ->helperText('Choose where this banner will be displayed'),

                                Forms\Components\TextInput::make('sort_order')
                                    ->numeric()
                                    ->default(0)
                                    ->required()
                                    ->helperText('Lower numbers appear first'),

                                Forms\Components\Toggle::make('is_active')
                                    ->default(true)
                                    ->helperText('Toggle to show/hide banner'),
                            ]),

                        Grid::make(2)
                            ->schema([
                                Forms\Components\DateTimePicker::make('start_date')
                                    ->label('Start Date (Optional)')
                                    ->helperText('When should this banner start showing?'),

                                Forms\Components\DateTimePicker::make('end_date')
                                    ->label('End Date (Optional)')
                                    ->helperText('When should this banner stop showing?')
                                    ->afterOrEqual('start_date'),
                            ]),
                    ]),

                Section::make('Call to Action')
                    ->schema([
                        Grid::make(2)
                            ->schema([
                                Forms\Components\TextInput::make('button_text')
                                    ->required()
                                    ->maxLength(50)
                                    ->default('Shop Now')
                                    ->helperText('Text displayed on the button'),

                                Forms\Components\TextInput::make('link_url')
                                    ->url()
                                    ->placeholder('https://example.com')
                                    ->helperText('Where should the button link to?'),
                            ]),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image_path')
                    ->label('Image')
                    ->disk('public')
                    ->size(80)
                    ->square(),

                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('position')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'main' => 'success',
                        'side_top' => 'info',
                        'side_bottom' => 'warning',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'main' => 'Main Banner',
                        'side_top' => 'Side Top',
                        'side_bottom' => 'Side Bottom',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('sort_order')
                    ->label('Order')
                    ->sortable()
                    ->alignCenter(),

                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Active')
                    ->alignCenter(),

                Tables\Columns\TextColumn::make('start_date')
                    ->dateTime('M j, Y')
                    ->sortable()
                    ->placeholder('No start date')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('end_date')
                    ->dateTime('M j, Y')
                    ->sortable()
                    ->placeholder('No end date')
                    ->toggleable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('position')
                    ->options([
                        'main' => 'Main Banner',
                        'side_top' => 'Side Top',
                        'side_bottom' => 'Side Bottom',
                    ]),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Active Status')
                    ->boolean()
                    ->trueLabel('Active banners only')
                    ->falseLabel('Inactive banners only')
                    ->native(false),

                Tables\Filters\Filter::make('scheduled')
                    ->query(fn (Builder $query): Builder => $query->whereNotNull('start_date'))
                    ->label('Scheduled Banners'),
            ])
            ->actions([
                Action::make('toggle_status')
                    ->label(fn (Banner $record): string => $record->is_active ? 'Deactivate' : 'Activate')
                    ->icon(fn (Banner $record): string => $record->is_active ? 'heroicon-o-eye-slash' : 'heroicon-o-eye')
                    ->color(fn (Banner $record): string => $record->is_active ? 'warning' : 'success')
                    ->action(function (Banner $record): void {
                        $record->update(['is_active' => !$record->is_active]);

                        Notification::make()
                            ->title('Banner ' . ($record->is_active ? 'activated' : 'deactivated'))
                            ->success()
                            ->send();
                    })
                    ->requiresConfirmation(),

                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),

                    Tables\Actions\BulkAction::make('activate')
                        ->label('Activate Selected')
                        ->icon('heroicon-o-eye')
                        ->color('success')
                        ->action(function ($records): void {
                            $records->each->update(['is_active' => true]);

                            Notification::make()
                                ->title('Selected banners activated')
                                ->success()
                                ->send();
                        })
                        ->requiresConfirmation(),

                    Tables\Actions\BulkAction::make('deactivate')
                        ->label('Deactivate Selected')
                        ->icon('heroicon-o-eye-slash')
                        ->color('warning')
                        ->action(function ($records): void {
                            $records->each->update(['is_active' => false]);

                            Notification::make()
                                ->title('Selected banners deactivated')
                                ->success()
                                ->send();
                        })
                        ->requiresConfirmation(),
                ]),
            ])
            ->defaultSort('sort_order')
            ->reorderable('sort_order')
            ->paginationPageOptions([10, 25, 50]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBanners::route('/'),
            'create' => Pages\CreateBanner::route('/create'),
            'edit' => Pages\EditBanner::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count();
    }

    public static function getNavigationBadgeColor(): string|array|null
    {
        return 'success';
    }
}
